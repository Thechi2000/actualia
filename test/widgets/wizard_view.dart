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

class WizardWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsSettingsViewModel _model;

  WizardWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsSettingsViewModel>(
                create: (context) => _model)
          ],
          child: _child,
        ));
  }
}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets('Has all correct inputs', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
        WizardWrapper(const WizardView(), MockNewsSettingsViewModel()));

    expect(find.text('Select some interests'), findsOne);
    expect(find.text('Select some countries'), findsOne);
    expect(find.text('Select some cities'), findsOne);
    expect(find.text('Validate'), findsOne);
  });
}
