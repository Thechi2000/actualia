// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { assertHasEnv } from "../util.ts";
import {
  isIn,
  isNumber,
  nullable,
  required,
  validate,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

const bodySchema = {
  transcriptId: [required, isNumber],
  voiceWanted: [
    isIn(["echo", "alloy", "fable", "onyx", "nova", "shimmer"]),
    nullable,
  ],
};

Deno.serve(async (req) => {
  assertHasEnv("OPENAI_API_KEY");

  const body = await req.json();
  const [passes, errors] = await validate(body, bodySchema);
  if (!passes) {
    console.log(`Invalid body: ${JSON.stringify(errors)}`);
    return new Response(JSON.stringify({ errors }), { status: 400 });
  }

  const transcriptId: number = body.transcriptId;
  const voiceWanted: string = body.voiceWanted || "echo";

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  console.log(
    "Generating audio for transcriptId:",
    transcriptId,
  );

  // We get the transcript from the database
  const { data, error } = await supabaseClient
    .from("news")
    .select()
    .eq("id", transcriptId);

  if (error) {
    console.error("Error getting transcript:", error);
    return new Response("Error getting transcript", { status: 500 });
  }
  if (!data || data.length === 0) {
    console.error("Transcript not found");
    return new Response("Transcript not found", { status: 404 });
  }

  // Verify that the file is not already existing in the db before generating it (audio column is empty)
  if (data[0].audio) {
    console.log("Audio already generated:", data[0].audio);
    return new Response(data[0].audio, { status: 200 });
  }

  const user = data[0].user;
  const transcript = data[0].transcript;
  const full_transcript = transcript.news.reduce(
    (accumulator: string, article: any) =>
      accumulator + article.transcript + "\n",
    "",
  );
  const path = `${user}/${transcriptId}.mp3`;

  const openai = new OpenAI();
  try {
    const audio = await openai.audio.speech.create({
      model: "tts-1",
      voice: voiceWanted as any,
      input: full_transcript,
    });

    const file = await audio.blob(); // Get the audio as a Blob

    const { data, error } = await supabaseClient.storage.from("audios").upload(
      path,
      file,
    );
    if (error) {
      console.error("Error uploading audio:", error);
      return new Response("Error uploading audio", { status: 500 });
    }

    console.log("Audio generated and uploaded:", data.path);

    // We update the transcript with the audio URL
    const { error: updateError } = await supabaseClient
      .from("news")
      .update({ audio: path })
      .eq("id", transcriptId);
    if (updateError) {
      console.error("Error updating transcript:", updateError);
      return new Response("Error updating transcript", { status: 500 });
    }

    return new Response(data.path, { status: 200 });
  } catch (error) {
    console.error("Error generating audio:", error);
    return new Response("Error generating audio", { status: 500 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-audio' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
