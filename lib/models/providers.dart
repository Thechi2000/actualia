/// List all available provider types, as well as useful informations for display
enum ProviderType {
  telegram("/telegram/channel", "Telegram", parameters: ["Channel ID"]),
  google("/google/news/:category", "Google News"),
  ;

  /// Base url of the provider, used for matching
  final String basePath;

  /// Name of the provider
  final String displayName;

  /// Display name of the additional parameters.
  /// They are appended in the url in the same order as provided.
  final List<String> parameters;

  const ProviderType(this.basePath, this.displayName,
      {this.parameters = const []});

  /// Converts a url to a display name, by matching the base path and extracting its parameters.
  /// If the url is a full RSS feed, uses the host name (without extension).
  static String displayString(String url) {
    if (url.startsWith("/")) {
      var type = ProviderType.values
          .firstWhere((element) => url.startsWith(element.basePath));

      var end = url.substring(type.basePath.length);

      var parameters = end
          .split("/")
          .where((element) => element.isNotEmpty && !element.startsWith(":"))
          .join(", ");

      return parameters.isEmpty
          ? type.displayName
          : "${type.displayName} ($parameters)";
    } else {
      var name = (RegExp(r"https?:\/\/(?:[^./]+\.)*([^./]+)\.[^./]+(?:\/.*)?")
                  .firstMatch(url)
                  ?.group(1) ??
              "")
          .replaceAll("[^a-zA-Z0-9]", " ");

      return "RSS ($name)";
    }
  }
}

class NewsProvider {
  final String url;

  NewsProvider({required this.url});

  String displayName() {
    return ProviderType.displayString(url);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsProvider && url == other.url;
  }

  @override
  int get hashCode => url.hashCode;
}
