// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import {
  isString,
  validate,
  validateArray,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

interface Body {
  categories: string[];
}
const schema = {
  categories: validateArray(true, [isString]),
};

Deno.serve(async (request) => {
  if (!Deno.env.has("GNEWS_API_KEY")) {
    console.error(
      "Missing GNews API key. Have you forgot the `GNEWS_API_KEY` variable in your `.env` file",
    );
    return new Response("Internal Server Error", { status: 500 });
  }

  const requestBody = await request.json();
  const [passes, errors] = await validate(requestBody, schema);
  if (!passes) {
    return new Response(JSON.stringify({ status: 400, errors }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const body: Body = requestBody;
  const query = encodeURIComponent(
    body.categories.map((s) => `"${s}"`).join(" OR "),
  );

  const url = `https://gnews.io/api/v4/search?q=${query}&apikey=${
    Deno.env.get("GNEWS_API_KEY")
  }`;

  const result = await fetch(url);
  const json = await result.json();

  console.log(result);
  console.log(json);

  return new Response(
    JSON.stringify(json),
    { headers: { "Content-Type": "application/json" } },
  );
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get-news' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
