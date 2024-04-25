import 'dart:developer';
import 'package:logging/logging.dart';

class GNewsProvider extends NewsProvider {
  @override
  serialize() {
    return {"type": "gnews"};
  }

  @override
  String displayName() {
    return "Google News";
  }
}

class RSSFeedProvider extends NewsProvider {
  final String url;

  RSSFeedProvider({required this.url});

  @override
  serialize() {
    return {"type": "rss", "url": url};
  }

  @override
  String displayName() {
    var name = (RegExp(r"https?:\/\/(?:[^./]+\.)*([^./]+)\.[^./]+(?:\/.*)?")
                .firstMatch(url)
                ?.group(1) ??
            "")
        .replaceAll("[^a-zA-Z0-9]", " ")
        .toUpperCase();

    return "$name (RSS)";
  }
}

abstract class NewsProvider {
  static NewsProvider? deserialize(dynamic dict) {
    try {
      switch (dict['type']) {
        case "gnews":
          return GNewsProvider();
        case "rss":
          return RSSFeedProvider(url: dict['url']);
        default:
          log("Unknown provider type: ${dict['type']}",
              level: Level.WARNING.value);
          return null;
      }
    } catch (e) {
      log("Unable to parse provider: $e", level: Level.WARNING.value);
      return null;
    }
  }

  dynamic serialize();

  String displayName();
}
