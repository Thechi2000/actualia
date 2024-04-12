import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/profile_view.dart';
import 'package:actualia/views/wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

// START: Shamelessly copied from Jacopo  that copied from internet.

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
    email: "test.test@epfl.ch",
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

class MockAuthModel extends AuthModel {
  MockAuthModel(super.key) {
    print("instantiated mockauth");
  }
}

// End

// START : Taken from Ludovic

class MockNewsSettingsViewModel extends NewsSettingsViewModel {
  MockNewsSettingsViewModel() : super(FakeSupabaseClient()) {
    super.setSettings(NewsSettings.defaults());
  }

  @override
  Future<void> fetchSettings() {
    notifyListeners();
    return Future.value();
  }

  @override
  Future<bool> pushSettings(NewsSettings settings) {
    return Future.value(true);
  }
}

// End

class ProfilePageWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsSettingsViewModel _newsSettingsModel;
  late final AuthModel _authModel;

  ProfilePageWrapper(this._child, this._newsSettingsModel, this._authModel,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsSettingsViewModel>(
                create: (context) => _newsSettingsModel),
            ChangeNotifierProvider<AuthModel>(create: (context) => _authModel)
          ],
          child: _child,
        ));
  }
}

void main() {
  testWidgets("Has all correct buttons", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(ProfilePageWrapper(const ProfilePageView(),
        MockNewsSettingsViewModel(), MockAuthModel(FakeSupabase())));

    expect(find.text("Logout"), findsOne);
    expect(find.text("Interests"), findsOne);
    expect(find.text("Sources"), findsOne);
    expect(find.text("Alarm"), findsOne);
    expect(find.text("Manage Storage"), findsOne);
    expect(find.text("Narrator Settings"), findsOne);
    expect(find.text("Accessibility"), findsOne);
    expect(find.text("Done"), findsOne);
  });

  testWidgets("Correct username", (WidgetTester tester) async {
    await tester.pumpWidget(ProfilePageWrapper(const ProfilePageView(),
        MockNewsSettingsViewModel(), MockAuthModel(FakeSupabase())));

    expect(find.text("Hey, test.test@epfl.ch !"), findsOne);
  });
  ;
}
