import 'package:actualia/viewmodels/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/providers.dart';

class ProvidersWizardView extends StatefulWidget {
  final bool isInitialOnboarding;

  const ProvidersWizardView({super.key, this.isInitialOnboarding = false});

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

class _ProvidersWizardView extends State<ProvidersWizardView> {
  late List<NewsProvider> _newsProviders;
  late ProvidersViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<ProvidersViewModel>(context);
    _vm.fetchNewsProviders();
    _newsProviders = _vm.newsProviders;
  }

  @override
  Widget build(BuildContext context) {
    return Text("data");
  }
}
