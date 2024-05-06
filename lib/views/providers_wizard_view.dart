import 'dart:developer';

import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';

class ProvidersWizardView extends StatefulWidget {
  const ProvidersWizardView({super.key});

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

enum WizardStep { PREDEFINED, RSS }

class _ProvidersWizardView extends State<ProvidersWizardView> {
  late List<(Object, String)> _selectedPredefinedProviders;
  List<(Object, String)>? _selectedRssProviders;
  late WizardStep _step;

  @override
  void initState() {
    super.initState();
    _step = WizardStep.PREDEFINED;
  }

  @override
  Widget build(BuildContext context) {
    final ProvidersViewModel pvm = Provider.of<ProvidersViewModel>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    final List<(NewsProvider, String)> predefined =
        NewsProvider.predefinedProviders;
    List<(NewsProvider, String)> savedPredefinedProviders = pvm.newsProviders
            ?.where((p) => p.$1.runtimeType != RSSFeedProvider)
            .toList() ??
        [];
    List<(NewsProvider, String)> savedRSSProviders = pvm.newsProviders
            ?.where((p) => p.$1.runtimeType == RSSFeedProvider)
            .toList() ??
        [];

    Widget predefinedProvidersSelector = WizardSelector(
      items: predefined,
      selectedItems: savedPredefinedProviders,
      onPressed: (selected) {
        setState(() {
          _selectedPredefinedProviders = selected;
          _step = WizardStep.RSS;
        });
      },
      title: "Select a predefined source",
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        Navigator.pop(context);
      },
      key: const Key("predefined-providers-selector"),
    );

    Widget rssSelector = RSSSelector(
        title: "Enter url for the RSS source of your choice",
        buttonText: "Finish",
        isInitialOnboarding: auth.isOnboardingRequired,
        onCancel: () {
          setState(() {
            _step = WizardStep.PREDEFINED;
          });
        },
        selectedItems: savedRSSProviders,
        onSelect: (urlList) {
          _selectedRssProviders = urlList;
        },
        onPressed: () async {
          if ((_selectedRssProviders?.isEmpty ?? true) &&
              savedRSSProviders.isNotEmpty) {
            _selectedRssProviders = savedRSSProviders;
          }
          List<(NewsProvider, String)> selected = _selectedPredefinedProviders
              .map((e) => (e.$1 as NewsProvider, e.$2))
              .toList();
          selected.addAll(
              _selectedRssProviders?.map((e) => (e.$1 as NewsProvider, e.$2)) ??
                  []);
          pvm.setNewsProviders(selected);
          try {
            await pvm.pushNewsProviders();
            if (auth.isOnboardingRequired) {
              await auth.setOnboardingIsDone();
            }
          } catch (e) {
            log("error in news provider wizard: $e");
          }
          Navigator.pop(context);
        });

    Widget? body;
    switch (_step) {
      case WizardStep.PREDEFINED:
        body = predefinedProvidersSelector;
        break;
      case WizardStep.RSS:
        body = rssSelector;
        break;
    }

    return WizardScaffold(
      body: body,
    );
  }
}
