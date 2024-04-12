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

interface MergedData {
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
  if (interests.data === null) {
    console.error("We can't get the user's interests: " + interests.error);
    return new Response("Internal Server Error", { status: 500 });
  }
  console.log(interests);

  const test = await supabaseClient.from("news_settings").select(
    "*",
  );
  console.log(test);

  // Get the news from GNews.
  //const gNews = await getGNews(interests);
  const gNews = await getGNews("Computer Science");

  // Generate a transcript from the news.
  const articlesPrompt = generateArticlesPrompt(gNews);
  const transcript = await generateTranscript(articlesPrompt);

  // Merge the GNews and the transcript.
  const response = mergeJSON(gNews, transcript);

  // Insert the transcript into the database.
  const { data, error } = await supabaseClient.from("news").insert({
    user: userId,
    title: "Hello! This is your daily news",
    transcript: response,
  });

  if (error !== null) {
    console.error("Failed to insert the transcript: " + error);
    return new Response("Internal Server Error", { status: 500 });
  }
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
          'You are a journalist who provide a transcript from a selection of news that we give you right after. Create a valid JSON array from this news-cut transcript, as in the example here {"nb_news":"The number of news you proceed (ex. 4)","full_transcript":"This is the global summary. For exemple you can say hello, and continue with the summary of the news 1, which makes a valid transition to the news that follows, as the text will be displayed in full without interruption. And when it\'s finished, who can say for exemple see you tomorrow!","news":[{"transcript":"the summary of the news 1, which makes a valid transition to","titre":"The title of the news 1"},{"transcript":"the news that follows, as the text will be displayed in full without interruption.","titre":"The title of the news 2"}]} The full_transcript need to correspond EXACTLY to the sum of the strings transcript',
      },
      {
        "role": "user",
        "content":
          "In this list, we give you the article headlines. It's up to you to compose your own text according to these, and to make interesting transitions between news items (IMPORTANT). For exemple, you can use Also, On the other hand, etc. to do the transition between news. Please do so in the order of the following news items:\n\n" +
          articlesPrompt,
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
  const gNewsQuery = interests.data.length > 0
    ? (interests.data[0].interests as string[]).map((s) => `"${s}"`).join(
      " OR ",
    )
    : "";

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

function mergeJSON(json1: MergedData, json2: MergedData): MergedData {
  const mergedData: MergedData = {
    totalArticles: json2.totalArticles,
    totalNewsByLLM: json1.totalNewsByLLM,
    articles: json2.articles.map((article, index) => {
      return { ...article, ...json1.articles[index] };
    }),
  };

  return mergedData;
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
