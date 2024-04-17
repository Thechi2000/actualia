// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';

import 'package:actualia/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets('correctly displays text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const LoadingView(text: 'Loading something')));

    expect(find.text('Loading something'), findsOne);
  });
}
