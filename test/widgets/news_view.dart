import "package:actualia/models/news.dart";
import "package:actualia/viewmodels/news.dart";
import "package:actualia/views/news_view.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel() : super(FakeSupabaseClient());

  @override
  News? get news => News(
          title: "Title",
          date: "1970-01-01",
          transcriptID: -1,
          audio: null,
          paragraphs: [
            Paragraph(
                transcript: "text1",
                source: "source1",
                title: "title1",
                date: "1970-01-01",
                content: "content1"),
            Paragraph(
                transcript: "text2",
                source: "source2",
                title: "title2",
                date: "1970-01-01",
                content: "content2"),
            Paragraph(
                transcript: "text3",
                source: "source3",
                title: "title3",
                date: "1970-01-01",
                content: "content3"),
            Paragraph(
                transcript: "text4",
                source: "source4",
                title: "title4",
                date: "1970-01-01",
                content: "content4")
          ]);

  @override
  Future<void> getNews(DateTime date) {
    return Future.value();
  }
}

class NewsWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsViewModel _model;

  NewsWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsViewModel>(create: (context) => _model)
          ],
          child: _child,
        ));
  }
}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets("Has all correct title", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(NewsWrapper(const NewsView(), MockNewsViewModel()));
    await tester.pumpAndSettle();

    expect(find.text("Title"), findsOne);
  });
}