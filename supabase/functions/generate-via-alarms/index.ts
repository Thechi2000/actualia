// This function is called periodically to generate a new transcript & audio via alarms.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";

Deno.serve(async (req) => {
  // We get the timestamp of the request.
  const timestampz = new Date().toISOString();
  // We get the timetz of the request.
  const timetz = new Date().toLocaleTimeString();
  // We will generate new transcripts & audios between now and 1 hour from now, so :
  // We get the timetz of 1 hour from now.
  const timetz_plus_1h = new Date(Date.now() + 60 * 60 * 1000)
    .toLocaleTimeString();
  // We will remove the alarms that have "last_used" above "timestampz_minus_10h", so :
  // We get the timestampz of 10 hours ago.
  const timestampz_minus_10h = new Date(Date.now() - 22 * 60 * 60 * 1000)
    .toISOString();

  // We create a Supabase client with the service role key.
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // We get the alarms who have "timetz" between "timetz" and "timetz_plus_1h".
  // We remove the alarms that have "last_used" above "timestampz_minus_22h"
  const { data: alarms, error } = await supabaseClient
    .from("alarms")
    .select()
    .gte("timez", timetz)
    .lte("timez", timetz_plus_1h)
    .lte("last_used", timestampz_minus_10h);
  if (error) {
    console.error("Error getting alarms:", error);
    return new Response("Error getting alarms", { status: 500 });
  }

  // All the alarms have a row "transcript_id" that we use to get the list of transcripts to generate.
  const transcriptIds = alarms.map((alarm: { transcript_id: bigint }) =>
    alarm.transcript_id
  );

  // We get the list of transcripts to generate.
  const { data: transcripts, error: errorTranscripts } = await supabaseClient
    .from("news")
    .select()
    .in("id", transcriptIds);
  if (errorTranscripts) {
    console.error("Error getting transcripts:", errorTranscripts);
    return new Response("Error getting transcripts", { status: 500 });
  }

  // We verify we have the same number of transcripts as alarms (not critical)
  if (transcripts.length !== alarms.length) {
    console.error("Number of transcripts does not match number of alarms");
  }

  // We generate the transcripts & audios by calling edge functions "generate-transcript" & "generate-audio".
  for (let i = 0; i < transcripts.length; i++) {
    const transcript = transcripts[i];

    // Call the "generate-transcript" edge function
    const generateTranscriptResponse = await supabaseClient.rpc(
      "generate-transcript",
      { transcriptId: transcript.id },
    );

    if (generateTranscriptResponse.error) {
      console.error(
        "Error generating transcript:",
        generateTranscriptResponse.error.message,
      );
      return new Response("Error generating transcript", { status: 500 });
    }

    // Call the "generate-audio" edge function
    const generateAudioResponse = await supabaseClient.rpc("generate-audio", {
      transcriptId: transcript.id,
    });

    if (generateAudioResponse.error) {
      console.error(
        "Error generating audio:",
        generateAudioResponse.error.message,
      );
      return new Response("Error generating audio", { status: 500 });
    }
  }

  // Update the "alarms" colums last_used with the current timestampz.
  const { error: updateError } = await supabaseClient
    .from("alarms")
    .update({ last_used: timestampz })
    .gte("timez", timetz)
    .lte("timez", timetz_plus_1h)
    .lte("last_used", timestampz_minus_10h);
  if (updateError) {
    console.error("Error updating alarms:", updateError);
    return new Response("Error updating alarms", { status: 500 });
  }

  return new Response("All good captain", { status: 200 });
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-via-alarms' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
