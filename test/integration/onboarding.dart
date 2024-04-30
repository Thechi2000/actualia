import 'dart:convert';

import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
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
