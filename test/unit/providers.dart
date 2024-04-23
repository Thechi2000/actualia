import 'package:actualia/models/providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Correctly parses Gnews provider", () async {
    expect(NewsProvider.parse({"type": "gnews"}).runtimeType,
        equals(GNewsProvider));
  });

  test("Correctly parses RSS provider", () async {
    var provider =
        NewsProvider.parse({"type": "rss", "url": "https://rss.feed.org"});
    expect(provider.runtimeType, equals(RSSFeedProvider));
    expect((provider as RSSFeedProvider).url, equals("https://rss.feed.org"));
  });

  test('Handles missing type entry', () {
    expect(NewsProvider.parse({"url": "https://rss.feed.org"}), isNull);
  });

  test('Handles invalid parameters', () {
    expect(NewsProvider.parse([]), isNull);
  });

  test('Handles unknown type', () {
    expect(
        NewsProvider.parse(
            {"type": "not-a-type", "url": "https://rss.feed.org"}),
        isNull);
  });
}
