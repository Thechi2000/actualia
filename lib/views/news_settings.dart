import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late NewsSettingsViewModel _viewModel;
  late NewsSettings _defaultSettings;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<NewsSettingsViewModel>(context, listen: false);
    _defaultSettings =
        NewsSettings.defaults(); // Get the default settings from the model
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Preferences',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            CheckboxListTile(
              title: Text('Cities'),
              value: _defaultSettings.wantsCities,
              onChanged: (value) {
                setState(() {
                  _defaultSettings.wantsCities = value ?? false;
                });
              },
            ),
            if (_defaultSettings.wantsCities) ..._buildCitiesSelection(),
            SizedBox(height: 10.0),
            CheckboxListTile(
              title: Text('Countries'),
              value: _defaultSettings.wantsCountries,
              onChanged: (value) {
                setState(() {
                  _defaultSettings.wantsCountries = value ?? false;
                });
              },
            ),
            if (_defaultSettings.wantsCountries) ..._buildCountriesSelection(),
            SizedBox(height: 10.0),
            CheckboxListTile(
              title: Text('Interests'),
              value: _defaultSettings.wantsInterests,
              onChanged: (value) {
                setState(() {
                  _defaultSettings.wantsInterests = value ?? false;
                });
              },
            ),
            if (_defaultSettings.wantsInterests) ..._buildInterestsSelection(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
              },
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCitiesSelection() {
    return _defaultSettings.cities
        .map((city) => CheckboxListTile(
              title: Text(city),
              value: _viewModel.selectedCities.contains(city),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _viewModel.selectedCities.add(city);
                  } else {
                    _viewModel.selectedCities.remove(city);
                  }
                });
              },
            ))
        .toList();
  }

  List<Widget> _buildCountriesSelection() {
    return _defaultSettings.countries
        .map((country) => CheckboxListTile(
              title: Text(country),
              value: _viewModel.selectedCountries.contains(country),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _viewModel.selectedCountries.add(country);
                  } else {
                    _viewModel.selectedCountries.remove(country);
                  }
                });
              },
            ))
        .toList();
  }

  List<Widget> _buildInterestsSelection() {
    return _defaultSettings.interests
        .map((interest) => CheckboxListTile(
              title: Text(interest),
              value: _viewModel.selectedInterests.contains(interest),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _viewModel.selectedInterests.add(interest);
                  } else {
                    _viewModel.selectedInterests.remove(interest);
                  }
                });
              },
            ))
        .toList();
  }

  void _saveSettings() {
    _viewModel.pushSettings(_defaultSettings);
    // You might want to navigate to the next screen after saving settings
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NextScreen()));
  }
}
