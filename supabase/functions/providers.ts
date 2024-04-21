import { News, NewsSettings, Provider } from "../functions/model.ts";
import { parseFeed } from "https://deno.land/x/rss@1.0.2/mod.ts";

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
    switch (provider.type) {
      case "gnews": {
        console.info("Fetching from GNews");

        const topics: string[] = [];
        if (newsSettings.wants_interests) {
          topics.push(newsSettings.interests);
        }
        if (newsSettings.wants_countries) {
          topics.push(newsSettings.countries);
        }
        if (newsSettings.wants_cities) {
          topics.push(newsSettings.cities);
        }

        const query = topics.map((s) => `"${s}"`).join(" OR ");
        const url = `https://gnews.io/api/v4/search?q=${
          encodeURIComponent(query)
        }&apikey=${
          encodeURIComponent(Deno.env.get("GNEWS_API_KEY") || "")
        }&from=${
          encodeURIComponent(new Date(Date.now() - 86400000).toISOString())
        }&lang=en`;

        const news: GNewsOutput = await (await fetch(url)).json();

        return news.articles.map((a) => ({
          title: a.title,
          description: a.description,
          link: a.url,
          date: new Date(a.publishedAt),
        }));
      }
      case "rss": {
        console.info("Fetching RSS from ", provider.url);

        const response = await fetch(
          provider.url,
        );
        const xml = await response.text();
        const feed = await parseFeed(xml);

        feed.entries.forEach((e) => console.log(e));
        const news = feed.entries.map((i) => ({
          title: i.title?.value || "",
          description: i.description?.value || "",
          date: i.published || new Date(Date.now()),
          link: i.links[0].href || "",
        }))
          .filter((i: News) => (Date.now() - i.date.getTime()) < 86400000);

        // TODO: Filter news according to user settings.

        return news;
      }
      default:
        throw new Error(
          `Unknown provider: ${(provider as { type: string }).type}`,
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
