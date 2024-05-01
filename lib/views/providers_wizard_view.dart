import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';

class ProvidersWizardView extends StatefulWidget {
  final bool isInitialOnboarding;

  const ProvidersWizardView({super.key, this.isInitialOnboarding = false});

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

class _ProvidersWizardView extends State<ProvidersWizardView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Text("TODO");
  }
}
