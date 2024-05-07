import 'package:actualia/models/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ProviderWrapper extends StatelessWidget {
  late final Widget _child;

  ProviderWrapper(this._child, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Material(child: _child));
  }
}

void main() {
  testWidgets("Correctly display initial data", (tester) async {
    var w = ProviderWidget(NewsProvider(url: "/telegram/channel/clicnews"),
        onDelete: (e) {});
    await tester.pumpWidget(ProviderWrapper(w));

    expect(find.textContaining("Telegram"), findsOneWidget);
    expect(find.textContaining("clicnews"), findsOneWidget);
    expect(w.toProvider().url, equals("/telegram/channel/clicnews"));
  });

  testWidgets("Defaults to empty RSS", (tester) async {
    var w = ProviderWidget(null, onDelete: (e) {});
    await tester.pumpWidget(ProviderWrapper(w));

    expect(find.textContaining("RSS"), findsOneWidget);
    expect(w.toProvider().url, equals(""));
  });

  testWidgets("Can delete", (tester) async {
    var deleted = false;
    await tester.pumpWidget(ProviderWrapper(ProviderWidget(
        NewsProvider(url: "/telegram/channel/clicnews"), onDelete: (e) {
      deleted = true;
    })));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets("Can change type", (tester) async {
    var w = ProviderWidget(NewsProvider(url: "/telegram/channel/clicnews"),
        onDelete: (e) {});
    await tester.pumpWidget(ProviderWrapper(w));

    await tester.tap(find.textContaining("Telegram"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("Google News"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Google News"), findsOneWidget);
    expect(w.toProvider().url, equals(ProviderType.google.basePath));
  });

  testWidgets("Can change field", (tester) async {
    var w = ProviderWidget(NewsProvider(url: "/telegram/channel/clicnews"),
        onDelete: (e) {});
    await tester.pumpWidget(ProviderWrapper(w));

    await tester.enterText(find.textContaining("clicnews"), "clic_bonplans");
    await tester.pumpAndSettle();

    expect(find.textContaining("Telegram"), findsOneWidget);
    expect(find.textContaining("clic_bonplans"), findsOneWidget);
    expect(w.toProvider().url, equals("/telegram/channel/clic_bonplans"));
  });
}
