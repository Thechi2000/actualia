import 'package:actualia/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableFab Tests', () {
    testWidgets('Widget Initialization Test', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ExpandableFab(
            distance: 100.0,
            children: [
              ActionButton(icon: Icon(Icons.add)),
              ActionButton(icon: Icon(Icons.remove)),
            ],
          ),
        ),
      );

      // Verify initialization
      expect(find.byType(ExpandableFab), findsOneWidget);
      expect(find.byType(ActionButton), findsNWidgets(2));
    });

    testWidgets('Toggle Test', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ExpandableFab(
            distance: 100.0,
            children: [
              ActionButton(icon: Icon(Icons.add)),
              ActionButton(icon: Icon(Icons.remove)),
            ],
          ),
        ),
      );

      // Tap to open
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      // Verify expansion
      expect(find.byType(ActionButton), findsNWidgets(3));

      // Tap to close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify collapse
      expect(find.byType(ActionButton), findsNWidgets(1));
    });
  });
}
