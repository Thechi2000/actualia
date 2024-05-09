import 'package:actualia/models/providers.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

class WizardSelector extends StatefulWidget {
  final String title;
  final String buttonText;
  final List<(Object, String)> items;
  final List<(Object, String)> selectedItems;
  final void Function(List<(Object, String)>) onPressed;
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
  late List<(Object, String)> _items;
  List<(Object, String)> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _selectedItems = widget.selectedItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget title = WizardSelectorTitle(title: widget.title);

    Widget body = Expanded(
        child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 24.0),
            child: SingleChildScrollView(
                child: Wrap(
                    spacing: UNIT_PADDING / 2,
                    runSpacing: UNIT_PADDING / 2.5,
                    alignment: WrapAlignment.center,
                    children: _items
                        .map((e) => FilterChip(
                            label: Text(e.$2),
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

class WizardTopBar extends StatelessWidget {
  final String text;

  const WizardTopBar({super.key, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
      child: Text(
        text,
        textScaler: const TextScaler.linear(2.0),
        style: const TextStyle(
            fontFamily: 'EB Garamond',
            fontWeight: FontWeight.w700,
            color: Colors.black),
        maxLines: 2,
      ),
    );
  }
}

class WizardSelectorTitle extends StatelessWidget {
  final String title;

  const WizardSelectorTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        style: const TextStyle(
            fontFamily: "Fira Code",
            fontWeight: FontWeight.w700,
            fontSize: 32.0),
        textAlign: TextAlign.center,
        title);
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
      cancel =
          FilledButton.tonal(onPressed: onCancel, child: const Text("Cancel"));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [cancel, right]);
  }
}

class WizardScaffold extends StatelessWidget {
  final PreferredSizeWidget topBar;
  final Widget body;

  const WizardScaffold(
      {this.topBar = const TopAppBar(),
      this.body = const Text("unimplemented"),
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      body: Container(
        padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 48.0),
        alignment: Alignment.topCenter,
        child: body,
      ),
    );
  }
}

class RSSSelector extends StatefulWidget {
  final String title;
  final String buttonText;
  final bool isInitialOnboarding;
  final List<(NewsProvider, String)> selectedItems;
  final void Function(List<(NewsProvider, String)>) onSelect;
  final void Function() onPressed;
  final void Function()? onCancel;

  const RSSSelector(
      {required this.onSelect,
      required this.onPressed,
      this.title = "Default",
      this.buttonText = "Next",
      this.isInitialOnboarding = false,
      this.onCancel,
      this.selectedItems = const [],
      super.key});

  @override
  State<RSSSelector> createState() => _RSSSelector();
}

class _RSSSelector extends State<RSSSelector> {
  late TextEditingController _controller;
  List<(NewsProvider, String)> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedItems.toList();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget title = WizardSelectorTitle(
      title: widget.title,
    );

    Widget selectUrl = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          onSubmitted: (String url) {
            setState(() {
              if (url.isNotEmpty &&
                  !_selectedItems.map((e) => e.$2).contains(url)) {
                NewsProvider p = RSSFeedProvider(url: url);
                _selectedItems.add((p, p.displayName()));
              }
              widget.onSelect(_selectedItems);
            });
          },
        )),
        IconButton(
            onPressed: () {
              setState(() {
                _controller.clear();
              });
            },
            icon: const Icon(Icons.close))
      ],
    );

    Widget displaySelected = Expanded(
        child: Container(
      padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 24.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: _selectedItems
              .map((item) => OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedItems.remove(item);
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(item.$2), const Icon(Icons.close)],
                    ),
                  ))
              .toList(),
        ),
      ),
    ));

    Widget bottom = WizardNavigationBottomBar(
      showCancel: !widget.isInitialOnboarding,
      onCancel: widget.onCancel,
      showRight: true,
      rText: widget.buttonText,
      rOnPressed: () {
        widget.onPressed();
      },
    );

    return Column(
      children: [title, selectUrl, displaySelected, bottom],
    );
  }
}
