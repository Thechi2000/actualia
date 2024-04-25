// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { assertHasEnv } from "../util.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import googleNewsAPI from "https://esm.sh/google-news-json@2.1.0";

Deno.serve(async (req) => {
  assertHasEnv("OPENAI_API_KEY");

  const url = new URL(req.url);
  const userId = url.searchParams.get("userId");

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const newsSettings = await supabaseClient
    .from("news_settings").select()
    .eq("created_by", userId);
  if (newsSettings.error) {
    console.error("We can't get the news settings", newsSettings);
    return new Response("We can't get the news settings", { status: 500 });
  }

  console.log(newsSettings);

  let articles = await googleNewsAPI.getNews(
    googleNewsAPI.TOP_NEWS,
    null,
    "en-GB",
  );

  //console.log(articles);

  return new Response(articles, { status: 200 });
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-transcript' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
