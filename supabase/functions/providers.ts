import { News, NewsSettings, Provider } from "../functions/model.ts";
import { parseFeed } from "https://deno.land/x/rss@1.0.2/mod.ts";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";

interface GNewsOutput {
  totalArticles: number;
  articles: GNewsItem[];
}
interface GNewsItem {
  title: string;
  description: string;
  content: string;
  url: string;
  image: string;
  publishedAt: string;
}

/**
 * Fetch and normalize news from a given provider.
 * @param provider One or several providers where to fetch the news.
 * @param newsSettings The settings to filter the fetched news.
 * @returns The news of today from that provider.
 */
export async function fetchNews(
  provider: Provider | Provider[],
  newsSettings: NewsSettings,
): Promise<News[]> {
  async function singleFetch(
    provider: Provider,
    newsSettings: NewsSettings,
  ): Promise<News[]> {
    let topics: string[] = [];
    if (newsSettings.wants_interests) {
      topics = topics.concat(JSON.parse(newsSettings.interests));
    }
    if (newsSettings.wants_countries) {
      topics = topics.concat(JSON.parse(newsSettings.countries));
    }
    if (newsSettings.wants_cities) {
      topics = topics.concat(JSON.parse(newsSettings.cities));
    }

    switch (provider.type) {
      case "gnews": {
        console.info("Fetching from GNews");

        // Generate the url with the query, date API key and language parameters.
        const query = topics.map((s) => `"${s}"`).join(" OR ");
        const url = `https://gnews.io/api/v4/search?q=${
          encodeURIComponent(query)
        }&apikey=${
          encodeURIComponent(Deno.env.get("GNEWS_API_KEY") || "")
        }&from=${
          encodeURIComponent(new Date(Date.now() - 86400000).toISOString())
        }&lang=en`;

        // Get the news from GNews.
        const news: GNewsOutput = await (await fetch(url)).json();

        // Normalizes the output to the correct format.
        return news.articles.map((a) => ({
          title: a.title,
          description: a.description,
          link: a.url,
          date: new Date(a.publishedAt),
        }));
      }
      case "rss": {
        console.info("Fetching RSS from ", provider.url);

        // Fetches and parses the rss feed.
        const response = await fetch(
          provider.url,
        );
        const xml = await response.text();
        const feed = await parseFeed(xml);

        // Normalizes the output and filters out out of date news.
        const news = feed.entries.map((i) => ({
          title: i.title?.value || "",
          description: i.description?.value || "",
          date: i.published || new Date(Date.now()),
          link: i.links[0].href || "",
        }))
          .filter((i: News) => (Date.now() - i.date.getTime()) < 86400000);

        // Filter news by AI according to user settings.
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
                "You are a trained news assistant. You're given a JSON of news, and in this JSON you must select the news that matches the following themes:" +
                topics +
                "You return a JSON in the same form, but without the news that doesn't match the themes.",
            },
            {
              "role": "user",
              "content": JSON.stringify(news),
            },
          ],
        });

        // Verify that the completion is valid.
        let filteredNews = {news: [] as News[]};
        try {
          filteredNews = JSON.parse(
            completion.choices[0].message.content || "",
          );
        } catch (error) {
          console.error("Error parsing filtered news:", error);
        }
        return filteredNews.news;
      }
      default:
        throw new Error(
          `Unknown provider: ${JSON.stringify(provider)}`,
        );
    }
  }

  if (Array.isArray(provider)) {
    return (await Promise.all(
      provider.map((p) => singleFetch(p, newsSettings)),
    )).flat();
  } else {
    return await singleFetch(provider, newsSettings);
  }
}
