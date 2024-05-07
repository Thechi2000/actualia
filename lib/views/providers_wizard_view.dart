import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProvidersWizardView extends StatefulWidget {
  ProvidersWizardView({super.key}) : items = List.empty();
  List<ProviderWidget> items;

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
    /* final ProvidersViewModel pvm = Provider.of<ProvidersViewModel>(context);
    if (widget.items.isEmpty) {
      setState(() {
        widget.items =
            pvm.newsProviders?.map((e) => ProviderWidget(e)).toList() ?? [];
      });
    } */

    return ListView(physics: const NeverScrollableScrollPhysics(), children: [
      ...widget.items,
      TextButton(
          onPressed: () =>
              setState(() => widget.items.add(ProviderWidget(null))),
          child: Text("Add"))
    ]);
  }
}
