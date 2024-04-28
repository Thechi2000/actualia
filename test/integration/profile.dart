import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_wrapper.dart';

void main() async {
  testWidgets('Can login and log out', (tester) async {
    print("Launching app...");
    // Load app widget.
    await tester.pumpWidget(AppWrapper());

    print("Login...");
    final loginButton = find.byKey(const Key("signin-guest"));
    // Verify the counter starts at 0.
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    print("Going to profile...");
    final profileButton = find.byKey(const Key("profile"));
    expect(profileButton, findsOneWidget);

    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    print("Logout...");
    final logoutButton = find.text('Logout');
    expect(logoutButton, findsOneWidget);

    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    print("Looking for login...");
    expect(loginButton, findsOneWidget);
  });
}
