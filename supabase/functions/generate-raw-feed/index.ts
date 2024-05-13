import { assertHasEnv } from "../util.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";
import { NewsSettings } from "../model.ts";
import { fetchNews } from "../providers.ts";

Deno.serve(async (request) => {
  assertHasEnv("RSSHUB_BASE_URL");

  // Create a Supabase client with the user's token.
  const authHeader = request.headers.get("Authorization")!;
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  // Get the user from the token.
  const user = await supabaseClient.auth.getUser();
  if (user.error !== null) {
    console.error(user.error);
    return new Response("Authentication error", { status: 401 });
  }
  const userId = user.data.user.id;
  console.log("We start the process for the user with ID:", userId);

  // Get the user's interests.
  console.log("Fetching user settings");
  const interestsDB = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", userId)
    .filter("wants_interests", "eq", true);

  if (interestsDB.error) {
    console.error("We can't get the user's interests");
    console.error(interestsDB.error);
    return new Response("Internal Server Error", { status: 500 });
  }
  const interests: NewsSettings = interestsDB.data[0];

  // Get the news.
  console.log(`Fetching news from ${interests.providers.length} providers`);
  const news = await fetchNews(interests.providers || [], interests);

  return new Response(JSON.stringify(news), { status: 200 });
});
