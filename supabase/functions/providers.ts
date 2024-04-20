import { News, NewsSettings, Provider } from "../functions/model.ts";
import { parseFeed } from "https://deno.land/x/rss@1.0.2/mod.ts";

/**
 * Fetch and normalize news from a given provider.
 * @param provider The provider where to fetch the news.
 * @param newsSettings The settings to filter the fetched news.
 * @returns The news of today from that provider.
 */
export async function fetchNews(
  provider: Provider,
  newsSettings: NewsSettings,
): Promise<News[]> {
  switch (provider.type) {
    case "gnews": {
      return [];
    }
    case "rss": {
      console.info("Fetching RSS from ", provider.url);
      const response = await fetch(
        provider.url,
      );
      const xml = await response.text();
      const feed = await parseFeed(xml);

      feed.entries.forEach((e) => console.log(e));
      return feed.entries.map((i) => ({
        title: i.title?.value || "",
        description: i.description?.value || "",
        date: i.published || new Date(Date.now()),
        link: i.links[0].href || "",
      }))
        .filter((i: News) => (Date.now() - i.date.getTime()) < 86400000);
    }
    default:
      throw new Error(
        `Unknown provider: ${(provider as { type: string }).type}`,
      );
  }
}
