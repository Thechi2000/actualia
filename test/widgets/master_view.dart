import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/views/master_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/navigation_menu.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel() : super(FakeSupabaseClient());
}

class MasterWrapper extends StatelessWidget {
  final Widget master;
  final NewsViewModel model;

  const MasterWrapper(this.master, this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsViewModel>(create: (context) => model)
        ],
        child: MaterialApp(
            title: "ActualIA", theme: ACTUALIA_THEME, home: master));
  }
}

void main() {
  testWidgets('MasterView contains bottom bar', (WidgetTester tester) async {
    await tester
        .pumpWidget(MasterWrapper(const MasterView(), MockNewsViewModel()));
    //find the app bar
    expect(find.byType(ActualiaBottomNavigationBar), findsOneWidget);
    expect(find.byType(TopAppBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();
    expect(find.byType(NewsView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.feed));
    await tester.pumpAndSettle();
    expect(find.byType(NewsView), findsNothing);
  });
}
