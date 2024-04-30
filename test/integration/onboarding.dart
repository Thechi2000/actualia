import 'dart:convert';

import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'app_wrapper.dart';

class MockHttp extends Fake implements Client {
  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      var b = json.decode(body as String);

      switch (url.toString()) {
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/auth/v1/token?grant_type=password":
          expect(b['email'], equals("actualia@example.com"));
          expect(b['password'], equals("actualia"));
          return Response(
              '{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6InhUbGZqNjBHZHFzVmlmUEEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzE0NDgzMTQ1LCJpYXQiOjE3MTQ0Nzk1NDUsImlzcyI6Imh0dHBzOi8vZHB4ZGRianlqZHNjdnVod3V0d3Uuc3VwYWJhc2UuY28vYXV0aC92MSIsInN1YiI6IjA0NDhkZGEwLWQzNzMtNGI3My04YTA0LTc1MDdhZjBiMmQ2YyIsImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiMDQ0OGRkYTAtZDM3My00YjczLThhMDQtNzUwN2FmMGIyZDZjIn0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MTQ0Nzk1NDV9XSwic2Vzc2lvbl9pZCI6IjdlNzVhMmE1LTQ0YjYtNDU3MS1iNTFkLThkYmExY2JkMWI5MyIsImlzX2Fub255bW91cyI6ZmFsc2V9.c6fzLvPzZPAQZVuu178lmjQc_w6UDdhBjWAJitMimZU","token_type":"bearer","expires_in":3600,"expires_at":1714483145,"refresh_token":"2IgxVlIyikNSCD_V20IMVQ","user":{"id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","aud":"authenticated","role":"authenticated","email":"actualia@example.com","email_confirmed_at":"2024-04-30T12:19:05.934212069Z","phone":"","last_sign_in_at":"2024-04-30T12:19:05.937201913Z","app_metadata":{"provider":"email","providers":["email"]},"user_metadata":{"email":"actualia@example.com","email_verified":false,"phone_verified":false,"sub":"0448dda0-d373-4b73-8a04-7507af0b2d6c"},"identities":[{"identity_id":"cc18cb14-f02d-4fd2-ac84-40846764cfeb","id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","user_id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","identity_data":{"email":"actualia@example.com","email_verified":false,"phone_verified":false,"sub":"0448dda0-d373-4b73-8a04-7507af0b2d6c"},"provider":"email","last_sign_in_at":"2024-04-30T12:19:05.92670308Z","created_at":"2024-04-30T12:19:05.926754Z","updated_at":"2024-04-30T12:19:05.926754Z","email":"actualia@example.com"}],"created_at":"2024-04-30T12:19:05.922289Z","updated_at":"2024-04-30T12:19:05.941017Z","is_anonymous":false}}',
              200);
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/auth/v1/token?grant_type=refresh_token":
          return Response(
              '{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6InhUbGZqNjBHZHFzVmlmUEEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzE0NDg3NDUxLCJpYXQiOjE3MTQ0ODM4NTEsImlzcyI6Imh0dHBzOi8vZHB4ZGRianlqZHNjdnVod3V0d3Uuc3VwYWJhc2UuY28vYXV0aC92MSIsInN1YiI6IjA0NDhkZGEwLWQzNzMtNGI3My04YTA0LTc1MDdhZjBiMmQ2YyIsImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiMDQ0OGRkYTAtZDM3My00YjczLThhMDQtNzUwN2FmMGIyZDZjIn0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MTQ0Nzk1NDV9XSwic2Vzc2lvbl9pZCI6IjdlNzVhMmE1LTQ0YjYtNDU3MS1iNTFkLThkYmExY2JkMWI5MyIsImlzX2Fub255bW91cyI6ZmFsc2V9.yx8ZA2kkkPV3shTNoeCf7yU53V2dK-FTEc9A1x-kuPY","token_type":"bearer","expires_in":3600,"expires_at":1714487451,"refresh_token":"yLZQCjM_LguWSKyo-ONyoA","user":{"id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","aud":"authenticated","role":"authenticated","email":"actualia@example.com","email_confirmed_at":"2024-04-30T12:19:05.934212Z","phone":"","confirmed_at":"2024-04-30T12:19:05.934212Z","last_sign_in_at":"2024-04-30T13:25:46.658214Z","app_metadata":{"provider":"email","providers":["email"]},"user_metadata":{"email":"actualia@example.com","email_verified":false,"phone_verified":false,"sub":"0448dda0-d373-4b73-8a04-7507af0b2d6c"},"identities":[{"identity_id":"cc18cb14-f02d-4fd2-ac84-40846764cfeb","id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","user_id":"0448dda0-d373-4b73-8a04-7507af0b2d6c","identity_data":{"email":"actualia@example.com","email_verified":false,"phone_verified":false,"sub":"0448dda0-d373-4b73-8a04-7507af0b2d6c"},"provider":"email","last_sign_in_at":"2024-04-30T12:19:05.926703Z","created_at":"2024-04-30T12:19:05.926754Z","updated_at":"2024-04-30T12:19:05.926754Z","email":"actualia@example.com"}],"created_at":"2024-04-30T12:19:05.922289Z","updated_at":"2024-04-30T13:30:51.825371Z","is_anonymous":false}}',
              200);
        default:
      }
      throw UnimplementedError(url.toString());
    });
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future(() {
      var req = request as http.Request;
      List<String> dynamicToString(dynamic l) {
        return (l as List<dynamic>).map((e) => e as String).toList();
      }

      switch (req.url.toString()) {
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/rest/v1/news_settings?on_conflict=created_by":
          var body = json.decode(req.body);

          expect(listEquals(dynamicToString(body['cities']), ['Lausanne']),
              isTrue);
          expect(listEquals(dynamicToString(body['countries']), ['Albania']),
              isTrue);
          expect(listEquals(dynamicToString(body['interests']), ['Gaming']),
              isTrue);
          return http.StreamedResponse(Stream.fromIterable(["".codeUnits]), 201,
              request: req);
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/rest/v1/news_settings?select=%2A&created_by=eq.0448dda0-d373-4b73-8a04-7507af0b2d6c":
          var res = jsonEncode({
            "id": 345,
            "created_at": "2024-04-30T14:39:28.189469+00:00",
            "created_by": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
            "interests": "[\"Gaming\"]",
            "wants_interests": true,
            "countries": "[\"Albania\"]",
            "wants_countries": true,
            "cities": "[\"Lausanne\"]",
            "wants_cities": true,
            "user_prompt": null,
            "providers_id": null,
            "voice_wanted": null
          }).codeUnits;
          return http.StreamedResponse(Stream.fromIterable([res]), 200,
              request: req, contentLength: res.length);
        default:
      }

      throw UnimplementedError(req.url.toString());
    });
  }
}

void main() async {
  testWidgets('User can go through onboarding then inspect profile',
      (tester) async {
    await tester.pumpWidget(AppWrapper(httpClient: MockHttp()));

    final loginButton = find.byKey(const Key("signin-guest"));
    // Verify the counter starts at 0.
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    Future<void> selectEntry(String selector, String entry) async {
      final selectorButton = find.byKey(Key(selector));
      expect(selectorButton, findsOneWidget);
      await tester.tap(selectorButton);
      await tester.pumpAndSettle();

      final entryButton = find.text(entry);
      await tester.dragUntilVisible(
          entryButton, find.byType(BottomSheet), const Offset(0, 10));
      await tester.tap(entryButton);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(DisplayList, entry), findsOneWidget);
    }

    await selectEntry("country-selector", "Albania");
    await selectEntry("city-selector", "Lausanne");
    await selectEntry("interest-selector", "Gaming");

    await tester.tap(find.text('Validate'));
    await tester.pump(Durations.long2);

    await tester.tap(find.byKey(const Key('profile')));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Interests"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(DisplayList, "Albania"), findsOneWidget);
    expect(find.widgetWithText(DisplayList, "Lausanne"), findsOneWidget);
    expect(find.widgetWithText(DisplayList, "Gaming"), findsOneWidget);
  });
}
