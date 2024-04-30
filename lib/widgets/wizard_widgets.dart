import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class WizardSelector extends StatefulWidget {
  final String title;
  final String buttonText;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onPressed;
  final bool isInitialOnboarding;
  final void Function()? onCancel;

  const WizardSelector(
      {required this.items,
      required this.onPressed,
      this.selectedItems = const [],
      this.title = "",
      this.buttonText = "Next",
      this.isInitialOnboarding = false,
      this.onCancel,
      super.key});

  @override
  State<WizardSelector> createState() => _WizardSelector();
}

class _WizardSelector extends State<WizardSelector> {
  late List<String> _items;
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    log("items: $_items", name: "DEBUG", level: Level.WARNING.value);
    _selectedItems = widget.selectedItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
        style: const TextStyle(
            fontFamily: "Fira Code",
            fontWeight: FontWeight.w700,
            fontSize: 32.0),
        textAlign: TextAlign.center,
        widget.title);

    Widget body = Expanded(
        child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
            child: SingleChildScrollView(
                child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: _items
                        .map((e) => FilterChip(
                            label: Text(e),
                            onSelected: (v) {
                              setState(() {
                                _selectedItems.contains(e)
                                    ? _selectedItems.remove(e)
                                    : _selectedItems.add(e);
                              });
                            },
                            selected: _selectedItems.contains(e)))
                        .toList()))));

    Widget bottomBar = WizardNavigationBottomBar(
      showCancel: !widget.isInitialOnboarding,
      onCancel: widget.onCancel,
      showRight: true,
      rText: widget.buttonText,
      rOnPressed: () {
        widget.onPressed(_selectedItems);
      },
    );

    return Column(
      children: [title, body, bottomBar],
    );
  }
}

class WizardNavigationBottomBar extends StatelessWidget {
  final bool showCancel;
  final bool showRight;
  final String rText;
  final void Function()? rOnPressed;
  final void Function()? onCancel;

  const WizardNavigationBottomBar(
      {this.showCancel = true,
      this.showRight = true,
      this.rText = "right button",
      this.rOnPressed,
      this.onCancel,
      super.key});

  @override
  Widget build(BuildContext context) {
    Widget right = const SizedBox();
    Widget cancel = const SizedBox();
    if (showRight) {
      right = FilledButton.tonal(onPressed: rOnPressed, child: Text(rText));
    }
    if (showCancel) {
      cancel = FilledButton.tonal(onPressed: onCancel, child: Text("Cancel"));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [cancel, right]);
  }
}
