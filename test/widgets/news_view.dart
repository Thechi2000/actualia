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
  News? get news => News(title: "Title", date: "1970-01-01", paragraphs: [
        Paragraph(text: "text1", source: "source1"),
        Paragraph(text: "text2", source: "source2"),
        Paragraph(text: "text3", source: "source3"),
        Paragraph(text: "text4", source: "source4")
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
