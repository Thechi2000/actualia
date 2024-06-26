// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:actualia/views/login_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// START: Shamelessly copied from the internet.

class FakeSupabase extends Fake implements SupabaseClient {
  @override
  get auth => FakeGotrue();
}

class FakeGotrue extends Fake implements GoTrueClient {
  final _user = User(
    id: 'id',
    appMetadata: {},
    userMetadata: {},
    aud: 'aud',
    createdAt: DateTime.now().toIso8601String(),
  );
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) async {
    return AuthResponse(
      session: Session(
        accessToken: '',
        tokenType: '',
        user: _user,
      ),
      user: _user,
    );
  }

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class FakeGoogleSignin extends Fake implements GoogleSignIn {}

// END;

class MockAuthModel extends AuthModel {
  MockAuthModel(super.key, super._googleSignIn);
}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets('testSignInButton', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const App());

    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: ListenableProvider<AuthModel>(
            create: (context) =>
                MockAuthModel(FakeSupabase(), FakeGoogleSignin()),
            builder: (context, child) => const LoginView())));
  });
}
