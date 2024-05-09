import 'dart:io';

import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProvidersWizardView extends StatefulWidget {
  ProvidersWizardView({this.cancelable = false, this.hasNext = true, super.key})
      : items = List.empty(growable: true);
  List<ProviderWidget> items;
  final bool cancelable;
  final bool hasNext;

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

    return WizardScaffold(
        body: Material(
            child: Column(children: [
      Text("Choose the sources for your news",
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: UNIT_PADDING),
      Expanded(
          child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...widget.items,
          FilledButton.tonal(
              onPressed: () => setState(() => widget.items
                  .add(ProviderWidget(null, onDelete: (w) => _removeItem(w)))),
              child: const Text("Add"))
        ],
      )),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        widget.cancelable
            ? FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"))
            : const SizedBox(),
        FilledButton.tonal(
            onPressed: () async {
              pvm.setNewsProviders(
                  widget.items.map((e) => e.toProvider()).toList());
              if (!await pvm.pushNewsProviders() && Platform.isAndroid) {
                Fluttertoast.showToast(msg: "Error while updating providers");
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(widget.hasNext ? "Next" : "Done"))
      ]),
    ])));
  }
}
