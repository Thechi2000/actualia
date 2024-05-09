import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/widgets/alarms_widget.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlarmWizardView extends StatefulWidget {
  const AlarmWizardView({super.key});

  @override
  State<AlarmWizardView> createState() => _AlarmWizardView();
}

class _AlarmWizardView extends State<AlarmWizardView> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime.now()
        .add(const Duration(minutes: 5))
        .copyWith(second: 0, millisecond: 0);
  }

  @override
  Widget build(BuildContext context) {
    AlarmsViewModel avm = Provider.of<AlarmsViewModel>(context);

    Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("work in progress"),
        PickTimeButton(
            initialTime: _selectedTime,
            onTimeSelected: (time) {
              _selectedTime = time;
            }),
        WizardNavigationBottomBar(
          rText: "close",
          rOnPressed: () => Navigator.pop(context),
        )
      ],
    );

    return WizardScaffold(
      body: body,
    );
  }
}
