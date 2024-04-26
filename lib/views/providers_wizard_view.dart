import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProvidersWizardView extends StatefulWidget {
  final bool isInitialOnboarding;

  const ProvidersWizardView({super.key, this.isInitialOnboarding = false});

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

class _ProvidersWizardView extends State<ProvidersWizardView> {
  List<String> _newsProviders = [];
  late List<String> _initialNewsProviders;
  late ProvidersViewModel _vm;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _vm = Provider.of<ProvidersViewModel>(context);
    _initialNewsProviders = _vm.providersToString(_vm.newsProviders);
    _newsProviders = _initialNewsProviders;

    PreferredSizeWidget topBar = const PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: WizardTopBar(
          text: "Select the sources that interests you",
        ));

    Widget body = Container(
        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: [
            SelectorWithInstruction(
              (value) {
                setState(() {
                  _newsProviders = value;
                });
              },
              "Select predefined sources",
              _vm.providersToString(NewsProvider.predefinedProviders),
              "Predefined sources",
              selectedItems: _newsProviders,
            ),
          ],
        ));

    Widget bottomBar = WizardNavigationBottomBar(
      showLeft: !widget.isInitialOnboarding,
      lText: "Cancel",
      lOnPressed: () {
        setState(() {
          _newsProviders = _initialNewsProviders;
        });
        Navigator.pop(context);
      },
      showRight: true,
      rText: "Finish",
      rOnPressed: () {
        _vm.setNewsProviders(_vm.stringToProviders(_newsProviders));
        _vm.pushNewsProviders();
        Navigator.pop(context); //todo popUntil
      },
    );

    Widget screen = _vm.newsProviders == null
        ? const LoadingView(text: "fetching your sources...")
        : Scaffold(
            appBar: topBar,
            body: body,
            bottomNavigationBar: bottomBar,
          );

    return screen;
  }
}
