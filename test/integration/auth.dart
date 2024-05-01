import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/response.dart';

import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
  @override
  get extraUserMetadata => {"onboardingDone": true};

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      switch (url.toString()) {
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/auth/v1/logout?scope=local":
          return Response("", 204);
      }

      return super.post(url, headers: headers, body: body, encoding: encoding);
    });
  }
}

void main() {
  testWidgets('User can login and logout', (tester) async {
    await tester.pumpWidget(AppWrapper(httpClient: MockHttp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("signin-guest")));
    await tester.pump(Durations.extralong2);

    await tester.tap(find.byKey(const Key("profile")));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("signin-guest")), findsOneWidget);
  });
}
