/// List all available provider types, as well as useful informations for display
enum ProviderType {
  telegram("/telegram/channel", "Telegram", parameters: ["Channel ID"]),
  epfl("https://actu.epfl.ch/feeds/rss/fr/", "Actu EPFL"),
  twentyMinutes("https://partner-feeds.20min.ch/rss/20minutes", "20 Minutes CH"),
  twentyMinutesFR("https://www.20minutes.fr/feeds/rss-une.xml", "20 Minutes FR"),
  google("/google/news/:query/en", "Google News"),
  franceInfo("https://www.francetvinfo.fr/france.rss", "France Info (France)"),
  franceInfoMonde("https://www.francetvinfo.fr/monde.rss", "France Info (Monde)"),
  rts("https://www.rts.ch/info/suisse?format=rss/news", "RTS (Suisse)"),
  rtsMonde("https://www.rts.ch/info/toute-info/?format=rss/news", "RTS (Monde)"),
  leMonde("https://www.lemonde.fr/rss/une.xml", "Le Monde (La une)"),
  leTemps("https://www.letemps.ch/articles.rss", "Le Temps"),
  rss("", "RSS", parameters: ["URL"]);

  /// Base url of the provider, used for matching
  final String basePath;

  /// Name of the provider
  final String displayName;

  /// Display name of the additional parameters.
  /// They are appended in the url in the same order as provided.
  final List<String> parameters;

  const ProviderType(this.basePath, this.displayName,
      {this.parameters = const []});
}

class NewsProvider {
  final String url;
  late final ProviderType type;
  late final List<String> parameters;

  NewsProvider({required this.url}) {
    type = ProviderType.values.firstWhere((e) => url.startsWith(e.basePath));
    if (type == ProviderType.rss) {
      parameters = [url];
    } else {
      parameters = url
          .substring(ProviderType.values
              .firstWhere((e) => url.startsWith(e.basePath))
              .basePath
              .length)
          .split("/")
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  String displayName() {
    if (type == ProviderType.rss) {
      var name = (RegExp(r"https?:\/\/(?:[^./]+\.)*([^./]+)\.[^./]+(?:\/.*)?")
                  .firstMatch(url)
                  ?.group(1) ??
              "")
          .replaceAll("[^a-zA-Z0-9]", " ");

      return "RSS ($name)";
    } else {
      return parameters.isEmpty
          ? type.displayName
          : "${type.displayName} (${parameters.join(", ")})";
    }
  }
}
