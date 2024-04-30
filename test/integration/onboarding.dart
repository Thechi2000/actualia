import 'dart:convert';

import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
  bool onboardingDone = false;

  @override
  get extraUserMetadata => {"onboardingDone": onboardingDone};

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
          return response({
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
          }, 200, req);

        case "https://dpxddbjyjdscvuhwutwu.supabase.co/rest/v1/news_settings?select=%2A&created_by=eq.a448dda0-d373-4b73-8a04-7507af0b2d6c":
          return response(
              onboardingDone
                  ? [
                      {
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
                      }
                    ]
                  : [],
              200,
              req);
        default:
      }

      return super.send(request);
    });
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      switch (url.toString()) {
        case "https://dpxddbjyjdscvuhwutwu.supabase.co/auth/v1/user?":
          expect(jsonDecode(body as dynamic)['data']['onboardingDone'], isTrue);
          onboardingDone = true;
          return http.Response(
            jsonEncode({
              "id": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
              "aud": "authenticated",
              "role": "authenticated",
              "email": "actualia@example.com",
              "email_confirmed_at": "2024-04-30T12:19:05.934212Z",
              "phone": "",
              "confirmed_at": "2024-04-30T12:19:05.934212Z",
              "last_sign_in_at": "2024-04-30T22:30:28.173036Z",
              "app_metadata": {
                "provider": "email",
                "providers": ["email"]
              },
              "user_metadata": {
                "email": "actualia@example.com",
                "email_verified": false,
                "onboardingDone": true,
                "phone_verified": false,
                "sub": "0448dda0-d373-4b73-8a04-7507af0b2d6c"
              },
              "identities": [
                {
                  "identity_id": "cc18cb14-f02d-4fd2-ac84-40846764cfeb",
                  "id": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
                  "user_id": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
                  "identity_data": {
                    "email": "actualia@example.com",
                    "email_verified": false,
                    "phone_verified": false,
                    "sub": "0448dda0-d373-4b73-8a04-7507af0b2d6c"
                  },
                  "provider": "email",
                  "last_sign_in_at": "2024-04-30T12:19:05.926703Z",
                  "created_at": "2024-04-30T12:19:05.926754Z",
                  "updated_at": "2024-04-30T12:19:05.926754Z",
                  "email": "actualia@example.com"
                }
              ],
              "created_at": "2024-04-30T12:19:05.922289Z",
              "updated_at": "2024-04-30T22:31:22.469535Z",
              "is_anonymous": false
            }),
            200,
          );
        default:
      }

      return super.put(url, headers: headers, body: body, encoding: encoding);
    });
  }
}

void main() async {
  testWidgets('User can go through onboarding then inspect profile',
      (tester) async {
    // Starts the app
    await tester.pumpWidget(AppWrapper(httpClient: MockHttp()));

    // Login as guest
    final loginButton = find.byKey(const Key("signin-guest"));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Util function to select an interest entry from a given list.
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

    // Select a few interests.
    await selectEntry("country-selector", "Albania");
    await selectEntry("city-selector", "Lausanne");
    await selectEntry("interest-selector", "Gaming");

    // Complete the onboarding.
    await tester.tap(find.text('Validate'));
    await tester.pump(Durations.long2);

    // Open the profile view.
    await tester.tap(find.byKey(const Key('profile')));
    await tester.pumpAndSettle();

    // Open the interests view.
    await tester.tap(find.text("Interests"));
    await tester.pumpAndSettle();

    // Checks that the interests are correctly displayed.
    expect(find.widgetWithText(DisplayList, "Albania"), findsOneWidget);
    expect(find.widgetWithText(DisplayList, "Lausanne"), findsOneWidget);
    expect(find.widgetWithText(DisplayList, "Gaming"), findsOneWidget);
  });
}
