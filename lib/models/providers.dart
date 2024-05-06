enum ProviderType {
  telegram("/telegram/channel", "Telegram", parameters: ["Channel ID"]),
  google("/google/news/:category", "Google News"),
  ;

  final String basePath;
  final String displayName;
  final List<String> parameters;
  const ProviderType(this.basePath, this.displayName,
      {this.parameters = const []});

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
