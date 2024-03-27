import {
  isString,
  validate,
  validateArray,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

// The query body.
interface Body {
  categories: string[];
}

// Schema object from Validasaur to verify the query body.
const schema = {
  categories: validateArray(true, [isString]),
};

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  if (!Deno.env.has("GNEWS_API_KEY")) {
    console.error(
      "Missing GNews API key. Have you forgot the `GNEWS_API_KEY` variable in your `.env` file",
    );
    return new Response("Internal Server Error", { status: 500 });
  }

  // Get and the request body and check it has the correct schema.
  const requestBody = await request.json();
  const [passes, errors] = await validate(requestBody, schema);
  if (!passes) {
    return new Response(JSON.stringify({ status: 400, errors }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Cast the validated body for easy use
  const body: Body = requestBody;

  // Computes the GNews query by ORing all the categories.
  // The categories must be "escaped" by putting them in quotes.
  // See https://gnews.io/docs/v4#search-endpoint-query-parameters for more details.
  const query = body.categories.map((s) => `"${s}"`).join(" OR ");

  // Constructs the query URL.
  const url = `https://gnews.io/api/v4/search?q=${
    encodeURIComponent(query)
  }&apikey=${encodeURIComponent(Deno.env.get("GNEWS_API_KEY") || "")}`;

  // Send the query and parse its result.
  const result = await fetch(url);
  const json = await result.json();

  // TODO: more advanced processing
  console.log(json);

  return new Response(
    JSON.stringify(json),
    { headers: { "Content-Type": "application/json" } },
  );
});
