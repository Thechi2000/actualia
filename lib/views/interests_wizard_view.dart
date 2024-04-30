import 'dart:developer';

import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../widgets/wizard_widgets.dart';

// TO REPLACE interests_wizard_view.dart
// sorry Leander

class InterestWizardView extends StatefulWidget {
  const InterestWizardView({super.key});

  @override
  State<InterestWizardView> createState() => _InterestWizardViewState();
}

enum WizardStep { COUNTRIES, CITIES, INTERESTS }

class _InterestWizardViewState extends State<InterestWizardView> {
  late List<String> _selectedInterests;
  late List<String> _selectedCountries;
  late List<String> _selectedCities;
  late WizardStep _step;

  @override
  void initState() {
    super.initState();
    _step = WizardStep.COUNTRIES;
  }

  @override
  Widget build(BuildContext context) {
    final NewsSettingsViewModel nsvm =
        Provider.of<NewsSettingsViewModel>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    final NewsSettings predefined = NewsSettings.defaults();
    _selectedCountries = nsvm.settings!.countries;
    _selectedCities = nsvm.settings!.cities;
    _selectedInterests = nsvm.settings!.interests;

    Widget countriesSelector = WizardSelector(
      items: predefined.predefinedCountries,
      onPressed: (selected) {
        setState(() {
          _selectedCountries = selected;
          _step = WizardStep.CITIES;
        });
        log("countries: $_selectedCountries, cities: $_selectedCities, interests: $_selectedInterests");
      },
      title: "Select countries",
      isInitialOnboarding: auth.isOnboardingRequired,
      key: const Key("countries-selector"),
    );

    Widget citiesSelector = WizardSelector(
      items: predefined.predefinedCities,
      onPressed: (selected) {
        setState(() {
          _selectedCities = selected;
          _step = WizardStep.INTERESTS;
        });
        log("countries: $_selectedCountries, cities: $_selectedCities, interests: $_selectedInterests");
      },
      title: "Select cities",
      isInitialOnboarding: auth.isOnboardingRequired,
      key: const Key("cities-selector"),
    );

    Widget interestsSelector = WizardSelector(
      items: predefined.predefinedInterests,
      onPressed: (selected) async {
        setState(() {
          _selectedInterests = selected;
        });
        log("countries: $_selectedCountries, cities: $_selectedCities, interests: $_selectedInterests");
        NewsSettings toSend = NewsSettings(
            cities: _selectedCities,
            countries: _selectedCountries,
            interests: _selectedInterests,
            wantsCities: true,
            wantsCountries: true,
            wantsInterests: true);
        try {
          await nsvm.pushSettings(toSend);
          await auth.setOnboardingIsDone();
        } catch (e) {
          debugPrint("error: $e");
          log("Error in wizard: $e", name: "ERROR", level: Level.WARNING.value);
        }
      },
      title: "Select interests",
      buttonText: "Finish",
      isInitialOnboarding: auth.isOnboardingRequired,
      key: const Key("interests-selector"),
    );

    Widget? body;
    switch (_step) {
      case WizardStep.COUNTRIES:
        body = countriesSelector;
        break;
      case WizardStep.CITIES:
        // body = Text("test");
        body = citiesSelector;
        break;
      case WizardStep.INTERESTS:
        body = interestsSelector;
        break;
    }

    return Scaffold(
        appBar: const TopAppBar(),
        body: Container(
          padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 48.0),
          alignment: Alignment.topCenter,
          child: body,
        ));
  }
}
