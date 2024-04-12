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

class MockAuthModel extends AuthModel {
  MockAuthModel(super.key) {
    print("instantiated mockauth");
  }

  @override
  User? get user => User(
        id: 'id',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        email: "test.test@epfl.ch",
        createdAt: DateTime.now().toIso8601String(),
      );

  Future<bool> signInWithGoogle() async {
    return Future.value(true);
  }
}

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
        MockNewsSettingsViewModel(), MockAuthModel(FakeSupabaseClient())));

    await tester.tap(find.byKey(const Key('Logout')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Interests')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Sources')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Alarm')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Manage Storage')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Narrator Settings')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Accessibility')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('Done')));
    await tester.pump();
  });

  testWidgets("Correct username", (WidgetTester tester) async {
    await tester.pumpWidget(ProfilePageWrapper(const ProfilePageView(),
        MockNewsSettingsViewModel(), MockAuthModel(FakeSupabaseClient())));

    expect(find.text("Hey, test.test@epfl.ch !"), findsOne);
  });
}
