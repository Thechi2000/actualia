import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wizard_widgets.dart';

class NewsAlertSetupView extends StatefulWidget {
  const NewsAlertSetupView({super.key});

  @override
  State<StatefulWidget> createState() => _NewsAlertSetupViewState();
}

class _NewsAlertSetupViewState extends State<NewsAlertSetupView> {
  late bool creating;
  late bool loading;

  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double volume;
  late String assetAudio;

  @override
  void initState() {
    super.initState();
    creating = true; // widget.alarmSettings == null;
    loading = false;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = 0.3;
      assetAudio = 'assets/test.mp3';
    } else {
      // selectedDateTime = widget.alarmSettings!.dateTime;
      // loopAudio = widget.alarmSettings!.loopAudio;
      // vibrate = widget.alarmSettings!.vibrate;
      // volume = widget.alarmSettings!.volume;
      // assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }

  Future<void> saveAlarm(BuildContext context) async {
    AlarmsViewModel model = Provider.of(context, listen: false);
    await model.setAlarm(
        selectedDateTime, assetAudio, loopAudio, vibrate, volume);
  }

  Future<void> testAlarm(BuildContext context) async {
    AlarmsViewModel model = Provider.of(context, listen: false);
    await model.setAlarm(
        DateTime.now(), assetAudio, loopAudio, vibrate, volume);
  }

  Future<void> deleteAlarm() async {}

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
        print("Selected date time : $selectedDateTime");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar = PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
          child: const Text(
            "Configure your 'News Alert'",
            textScaler: TextScaler.linear(2.0),
            style: TextStyle(
                fontFamily: 'EB Garamond',
                fontWeight: FontWeight.w700,
                color: Colors.black),
            maxLines: 2,
          ),
        ));

    Widget body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //// Maybe interesting ?
          // Text(
          //   getDay(),
          //   style: Theme.of(context)
          //       .textTheme
          //       .titleMedium!
          //       .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          // ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                TimeOfDay.fromDateTime(selectedDateTime).format(context),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                "${(volume * 100).round()}%",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    setState(() => volume = value);
                  },
                ),
              ),
            ],
          ),

          RawMaterialButton(
            onPressed: () => testAlarm(context),
            elevation: 2.0,
            fillColor: Colors.lightGreen,
            padding: const EdgeInsets.all(15.0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Text(
              "Test!",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white),
            ),
          ),

          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                'Delete Alarm',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );

    Widget bottomBar = WizardNavigationBottomBar(
        lText: 'Cancel',
        lOnPressed: () {
          Navigator.pop(context);
        },
        showRight: true,
        rText: 'Validate',
        rOnPressed: () async {
          saveAlarm(context);
          Navigator.pop(context);
        });

    return Scaffold(appBar: appBar, body: body, bottomNavigationBar: bottomBar);
  }
}
