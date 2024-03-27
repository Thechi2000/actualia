// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

Deno.serve(async (_req) => {
  if (!Deno.env.has("GNEWS_API_KEY")) {
    console.error(
      "Missing GNews API key. Have you forgot the `GNEWS_API_KEY` variable in your `.env` file",
    );
    return new Response("Internal Server Error", { status: 500 });
  }

  const url = `https://gnews.io/api/v4/search?q=example&apikey=${Deno.env.get("GNEWS_API_KEY")}`;

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
