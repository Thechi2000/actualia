import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

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

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets('Example test for widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsSettingsViewModel>(
                create: (context) => MockNewsSettingsViewModel())
          ],
          child: const WizardView(),
        )));
  });
}
