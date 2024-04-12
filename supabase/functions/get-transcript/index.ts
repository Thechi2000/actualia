import { assertHasEnv } from "../util.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";

interface News {
  transcript: string;
}

interface NewsJSONLLM {
  totalNewsByLLM: string;
  news: News[];
}

interface Article {
  title: string;
  description: string;
  content: string;
  url: string;
  image: string;
  publishedAt: string;
  source: {
    name: string;
    url: string;
  };
}

interface ArticlesResponse {
  totalArticles: number;
  articles: Article[];
}

interface MergedJSON {
  totalArticles: number;
  totalNewsByLLM: string;
  articles: (Article & News)[];
}

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  assertHasEnv("GNEWS_API_KEY");
  assertHasEnv("OPENAI_API_KEY");

  // Create a Supabase client with the user's token.
  const authHeader = request.headers.get("Authorization")!;
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  /*   // Get the user from the token.
  const user = await supabaseClient.auth.getUser();
  if (user.error !== null) {
    console.error(user.error);
    return new Response("Authentication error", { status: 401 });
  }
  const userId = user.data.user.id;
  console.log("User ID:", userId); */

  const userId = "48ecf965-4688-4b19-8af1-3df2fa50282b";

  // Get the user's interests.
  const interests = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", userId)
    .filter("wants_interests", "eq", true);
  if (interests.error) {
    console.error("We can't get the user's interests: " + interests.error);
    return new Response("Internal Server Error", { status: 500 });
  }
  console.log(interests);

  // Get the news from GNews.
  const gNews = await getGNews(interests);

  // Generate a transcript from the news.
  const articlesPrompt = generateArticlesPrompt(gNews);
  const transcript = await generateTranscript(articlesPrompt);

  // Merge the GNews and the transcript.
  const response = mergeJSON(transcript, gNews);
  console.log(response);

  // Insert the transcript into the database.
  const { data, error } = await supabaseClient.from("news").insert({
    user: userId,
    title: "Hello! This is your daily news",
    transcript: response,
  });

  console.log(data);

  // return transcript
  return new Response(JSON.stringify(transcript), {
    headers: { "content-type": "application/json" },
  });
});

// Call OpenAI API for json generation
async function generateTranscript(articlesPrompt: any) {
  const openai = new OpenAI();
  const completion = await openai.chat.completions.create({
    "model": "gpt-3.5-turbo",
    "response_format": {
      "type": "json_object",
    },
    "messages": [
      {
        "role": "system",
        "content":
          'You are a journalist who provide a transcript from a selection of article headlines that we give you. It\'s up to you to compose your own text according to these, and to make interesting transitions between transcript items (IMPORTANT). For exemple, you can use Also, On the other hand, etc. to do the transition between news. Create a valid JSON array from this news-cut transcript, as in the example here {"totalNewsByLLM":"The number of news you proceed (ex. 3 here)","news":[{"transcript":"The summary of the news 1"},{"transcript":"The summary of the news 2"},{"transcript":"etc."}]}',
      },
      {
        "role": "user",
        "content": articlesPrompt,
      },
    ],
  });

  const transcriptJSON = JSON.parse(
    completion.choices[0].message.content || "",
  );
  console.log(transcriptJSON);

  return transcriptJSON;
}

// Fetch GNews based on user's interests
async function getGNews(interests: any) {
  // Computes the GNews query by ORing all the categories.
  // The categories must be "escaped" by putting them in quotes.
  // See https://gnews.io/docs/v4#search-endpoint-query-parameters for more details.
  let gNewsQuery = interests && interests.data && interests.data.length > 0 &&
      interests.data[0].interests
    ? (interests.data[0].interests as string[]).map((s) => `"${s}"`).join(
      " OR ",
    )
    : "";

  if (!gNewsQuery) {
    console.error("No user's interests, we will use default ones.");
    gNewsQuery = "Microsoft OR OpenAI";
  }
  // Constructs the query URL.
  const url = `https://gnews.io/api/v4/search?q=${
    encodeURIComponent(gNewsQuery)
  }&max=3&apikey=${encodeURIComponent(Deno.env.get("GNEWS_API_KEY") || "")}`;

  // Send the query and parse its result.
  const result = await fetch(url);
  const json = await result.json();
  console.log(json);

  return json;
}

// Concatenate the articles into a single string to pass them to LLM
function generateArticlesPrompt(json: ArticlesResponse): string {
  let result: string = "";
  json.articles.forEach((article: Article) => {
    result += `${article.title}\n${article.description}\n\n`;
  });
  return result;
}

function mergeJSON(
  json1: MergedJSON,
  json2: { totalArticles: number; articles: Article[] },
): MergedJSON {
  console.log(json2);
  return {
    totalArticles: json2.totalArticles,
    totalNewsByLLM: json1.totalNewsByLLM,
    articles: json2.articles.map((article) => ({ ...article, transcript: "" })),
  };
}

// Verify the JSON structure of the OpenAI response
function verifyJSONStructure(jsonData: any): jsonData is NewsJSONLLM {
  if (
    typeof jsonData === "object" &&
    jsonData !== null &&
    typeof jsonData.totalNewsByLLM === "string" &&
    Array.isArray(jsonData.news) &&
    jsonData.news.every((item: any) => typeof item.transcript === "string")
  ) {
    return true;
  }
  return false;
}
