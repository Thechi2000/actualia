import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TO REPLACE wizard_view.dart
// sorry Leander

class Wizard extends StatefulWidget {
  @override
  _WizardState createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 48.0),
      alignment: Alignment.topCenter,
      child: WizardWidget(),
    ));
  }
}

class WizardWidget extends StatefulWidget {
  @override
  _WizardWidgetState createState() => _WizardWidgetState();
}

enum WizardStep { Interests, Countries, Cities, OVER }

class _WizardWidgetState extends State<WizardWidget> {
  List<String> selectedInterests = [];
  List<String> selectedCountries = [];
  List<String> selectedCities = [];
  WizardStep step = WizardStep.Countries;

  void nextStateOrDone(NewsSettingsViewModel nsvm, AuthModel am) async {
    switch (step) {
      case WizardStep.Countries:
        setState(() => step = WizardStep.Cities);
        break;
      case WizardStep.Cities:
        setState(() => step = WizardStep.Interests);
        break;
      case WizardStep.Interests:
        setState(() => step = WizardStep.OVER);
        NewsSettings toSend = NewsSettings(
          cities: selectedCities,
          countries: selectedCountries,
          interests: selectedInterests,
          wantsCities: true,
          wantsCountries: true,
          wantsInterests: true,
        );
        nsvm.pushSettings(toSend);
        await am.setOnboardingIsDone();
        debugPrint(nsvm.settings.toString());
        break;
      case WizardStep.OVER:
        debugPrint("UNREACHABLE");
        break;
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    NewsSettingsViewModel newsSettings =
        Provider.of<NewsSettingsViewModel>(context);
    AuthModel authModel = Provider.of<AuthModel>(context);

    List<String> interests = newsSettings.settings?.predefinedInterests ?? [];
    List<String> countries = newsSettings.settings?.predefinedCountries ?? [];
    List<String> cities = newsSettings.settings?.predefinedCities ?? [];

    switch (step) {
      case WizardStep.Interests:
        return ListView(shrinkWrap: true, children: <Widget>[
          const Text(
              style: TextStyle(
                  fontFamily: "Fira Code",
                  fontWeight: FontWeight.w700,
                  fontSize: 32.0),
              textAlign: TextAlign.center,
              "test"),
          Container(
              padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
              child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: interests
                      .map((e) => FilterChip(
                          label: Text(e),
                          onSelected: (v) => setState(() =>
                              selectedInterests.contains(e)
                                  ? selectedInterests.remove(e)
                                  : selectedInterests.add(e)),
                          selected: selectedInterests.contains(e)))
                      .toList())),
          FilledButton.tonal(
              onPressed: () => nextStateOrDone(newsSettings, authModel),
              child: const Text("Next"))
        ]);
      case WizardStep.Cities:
        return ListView(shrinkWrap: true, children: <Widget>[
          const Text(
              style: TextStyle(
                  fontFamily: "Fira Code",
                  fontWeight: FontWeight.w700,
                  fontSize: 32.0),
              textAlign: TextAlign.center,
              "test"),
          Container(
              padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
              child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: cities
                      .map((e) => FilterChip(
                          label: Text(e),
                          onSelected: (v) => setState(() =>
                              selectedCities.contains(e)
                                  ? selectedCities.remove(e)
                                  : selectedCities.add(e)),
                          selected: selectedCities.contains(e)))
                      .toList())),
          FilledButton.tonal(
              onPressed: () => nextStateOrDone(newsSettings, authModel),
              child: const Text("Next"))
        ]);
      case WizardStep.Countries:
        return ListView(shrinkWrap: true, children: <Widget>[
          const Text(
              style: TextStyle(
                  fontFamily: "Fira Code",
                  fontWeight: FontWeight.w700,
                  fontSize: 32.0),
              textAlign: TextAlign.center,
              "test"),
          Container(
              padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
              child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: countries
                      .map((e) => FilterChip(
                          label: Text(e),
                          onSelected: (v) => setState(() =>
                              selectedCountries.contains(e)
                                  ? selectedCountries.remove(e)
                                  : selectedCountries.add(e)),
                          selected: selectedCountries.contains(e)))
                      .toList())),
          FilledButton.tonal(
              onPressed: () => nextStateOrDone(newsSettings, authModel),
              child: const Text("Next"))
        ]);
      case WizardStep.OVER:
        return const Text("UNREACHABLE");
    }
  }
}
