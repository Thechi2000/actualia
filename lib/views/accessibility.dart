import 'dart:io';

import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AccessibilityView extends StatelessWidget {
  const AccessibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    var nsvm = Provider.of<NewsSettingsViewModel>(context);

    return WizardScaffold(
        body: Column(children: [
      Expanded(
          child: ListView(
        children: [
          Card(
            child: Container(
              padding: const EdgeInsets.all(UNIT_PADDING),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.accessibilityLanguage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    DropdownButton(
                      value: AppLocalizations.of(context)!.localeName,
                      items: AppLocalizations.supportedLocales
                          .map((l) => DropdownMenuItem(
                              value: l.toLanguageTag(),
                              child: Text(
                                l.toLanguageTag(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              )))
                          .toList(),
                      onChanged: (value) => nsvm.setLocale(value),
                    )
                  ]),
            ),
          )
        ],
      )),
      WizardNavigationBottomBar(
        showCancel: true,
        rText: AppLocalizations.of(context)!.done,
        rOnPressed: () async {
          if (!await nsvm.pushSettings(null)) {
            if (context.mounted && Platform.isAndroid) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.accessibilityUpdateError);
            }
          } else {
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      )
    ]));
  }
}
