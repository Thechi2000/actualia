// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { assertHasEnv } from "../util.ts";

Deno.serve(async (req) => {
  assertHasEnv("OPENAI_API_KEY");

  const url = new URL(req.url);
  const transcriptId = url.searchParams.get("transcriptId");

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  console.log(
    "Starting. We we'll generate audio for transcriptId:",
    transcriptId,
  );

  const openai = new OpenAI();
  try {
    const audio = await openai.audio.speech.create({
      model: "tts-1",
      voice: "alloy",
      input: "Today is a wonderful day to build something people love!",
    });

    const file = await audio.blob(); // Get the audio as a Blob

    const { data, error } = await supabaseClient.storage.from("audios").upload(
      "test",
      file,
    );
    if (error) {
      console.error("Error uploading audio:", error);
      return new Response("Error uploading audio", { status: 500 });
    }

    return new Response(
      JSON.stringify(data),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
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
