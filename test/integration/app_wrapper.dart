import 'package:actualia/main.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
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

void main() {}
