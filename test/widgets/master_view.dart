import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/views/master_view.dart';
import 'package:actualia/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel() : super(FakeSupabaseClient());
}

class NewsWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsViewModel _model;

  NewsWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsViewModel>(create: (context) => _model)
        ],
        child: MaterialApp(
            title: "ActualIA",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: _child));
  }
}

void main() {
  testWidgets('MasterView contains bottom bar', (WidgetTester tester) async {
    await tester
        .pumpWidget(NewsWrapper(const MasterView(), MockNewsViewModel()));
    //find the app bar
    expect(find.byType(ActualiaBottomNavigationBar), findsOne);
  });
}
