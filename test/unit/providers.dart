import 'package:actualia/models/providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Correctly serializes GNews provider", () {
    expect(GNewsProvider().serialize(), equals({"type": "gnews"}));
  });

  test("Correctly deserializes GNews provider", () async {
    expect(NewsProvider.deserialize({"type": "gnews"}).runtimeType,
        equals(GNewsProvider));
  });

  test("Correctly serializes RSS provider", () {
    expect(RSSFeedProvider(url: "https://rss.example.org").serialize(),
        equals({"type": "rss", "url": "https://rss.example.org"}));
  });

  test("Correctly deserializes RSS provider", () async {
    var provider = NewsProvider.deserialize(
        {"type": "rss", "url": "https://rss.feed.org"});
    expect(provider.runtimeType, equals(RSSFeedProvider));
    expect((provider as RSSFeedProvider).url, equals("https://rss.feed.org"));
  });

  test('Handles missing type entry', () {
    expect(NewsProvider.deserialize({"url": "https://rss.feed.org"}), isNull);
  });

  test('Handles invalid parameters', () {
    expect(NewsProvider.deserialize([]), isNull);
  });

  test('Handles unknown type', () {
    expect(
        NewsProvider.deserialize(
            {"type": "not-a-type", "url": "https://rss.feed.org"}),
        isNull);
  });
}
