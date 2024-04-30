import 'dart:convert';

import 'package:actualia/main.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppWrapper extends StatelessWidget {
  final Client? httpClient;

  const AppWrapper({super.key, this.httpClient});

  @override
  Widget build(BuildContext context) {
    SharedPreferences.setMockInitialValues({});

    Supabase.initialize(
        url: 'https://dpxddbjyjdscvuhwutwu.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRweGRkYmp5amRzY3Z1aHd1dHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQzNDcsImV4cCI6MjAyNjUzMDM0N30.0vB8huUmdJIYp3M1nMeoixQBSAX_w2keY0JsYj2Gt8c',
        httpClient: httpClient,
        debug: false,
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthModel(
                Supabase.instance.client,
                GoogleSignIn(
                  serverClientId:
                      '505202936017-bn8uc2veq2hv5h6ksbsvr9pr38g12gde.apps.googleusercontent.com',
                ))),
        ChangeNotifierProvider(
            create: (context) => NewsViewModel(Supabase.instance.client)),
        ChangeNotifierProvider(
            create: (context) =>
                NewsSettingsViewModel(Supabase.instance.client)),
      ],
      child: const App(),
    );
  }
}

// Mocked HttpClient implementing only the guest authentication requests.
class BaseMockedHttpClient extends Fake implements Client {
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
}

// Each test file must have a name.
void main() {}
