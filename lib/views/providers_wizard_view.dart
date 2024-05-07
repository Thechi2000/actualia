import 'dart:developer';

import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProvidersWizardView extends StatefulWidget {
  ProvidersWizardView({super.key}) : items = List.empty(growable: true);
  List<ProviderWidget> items;

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

class _ProvidersWizardView extends State<ProvidersWizardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProvidersViewModel>(context, listen: false)
            .fetchNewsProviders());
  }

  void _removeItem(ProviderWidget w) {
    setState(() => widget.items.remove(w));
  }

  @override
  Widget build(BuildContext context) {
    final ProvidersViewModel pvm = Provider.of<ProvidersViewModel>(context);
    if (widget.items.isEmpty) {
      setState(() {
        widget.items = pvm.newsProviders
                ?.map((e) => ProviderWidget(e, onDelete: (w) => _removeItem(w)))
                .toList() ??
            [];
      });
    }

    return Material(
        child:
            ListView(physics: const NeverScrollableScrollPhysics(), children: [
      ...widget.items,
      TextButton(
          onPressed: () => setState(() => widget.items
              .add(ProviderWidget(null, onDelete: (w) => _removeItem(w)))),
          child: const Text("Add")),
      TextButton(
          onPressed: () async {
            pvm.setNewsProviders(
                widget.items.map((e) => e.toProvider()).toList());
            if (!await pvm.pushNewsProviders()) {
              Fluttertoast.showToast(msg: "Error while updating providers");
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text("Validate"))
    ]));
  }
}
