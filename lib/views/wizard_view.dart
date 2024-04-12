import 'dart:developer';

import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wizard_widgets.dart';

class WizardView extends StatefulWidget {
  const WizardView({super.key});

  @override
  State<StatefulWidget> createState() => _WizardViewState();
}

class _WizardViewState extends State<WizardView> {
  List<String> _cities = [];
  List<String> _countries = [];
  List<String> _interests = [];

  @override
  Widget build(BuildContext context) {
    NewsSettingsViewModel? newsSettingsModel;
    NewsSettings newsSettingsDefault = NewsSettings.defaults();
    NewsSettings fromDB;

    newsSettingsModel = Provider.of<NewsSettingsViewModel>(context);
    fromDB = newsSettingsModel.settings;

    if (fromDB.countries.isNotEmpty) {
      _countries = fromDB.countries;
    }
    if (fromDB.cities.isNotEmpty) {
      _cities = fromDB.cities;
    }
    if (fromDB.interests.isNotEmpty) {
      _interests = fromDB.interests;
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
            child: const Text(
              "Tell us more about your interests",
              textScaler: TextScaler.linear(2.0),
              style: TextStyle(
                  fontFamily: 'EB Garamond',
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
              maxLines: 2,
            ),
          )),
      body: Container(
        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //each formField is an entry in the wizard
            SelectorWithInstruction(
              (value) {
                setState(() {
                  _countries = value;
                });
              },
              "Select some countries",
              newsSettingsDefault.predefinedCountries,
              "Country",
              selectedItems: _countries,
            ),
            SelectorWithInstruction(
              (value) {
                setState(() {
                  _cities = value;
                });
              },
              "Select some cities",
              newsSettingsDefault.predefinedCities,
              "City",
              selectedItems: _cities,
            ),
            SelectorWithInstruction(
              (value) {
                setState(() {
                  _interests = value;
                });
              },
              "Select some interests",
              newsSettingsDefault.predefinedInterests,
              "Interests",
              selectedItems: _interests,
            )
          ],
        ),
      ),
      bottomNavigationBar: WizardNavigationButton('Validate', () {
        NewsSettings toSend = NewsSettings(
            cities: _cities,
            countries: _countries,
            interests: _interests,
            wantsCities: true,
            wantsCountries: true,
            wantsInterests: true);
        newsSettingsModel?.pushSettings(toSend);
        //todo nav to main screen
      }),
    );
  }
}
