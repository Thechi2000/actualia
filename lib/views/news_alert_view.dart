import 'package:actualia/viewmodels/alarms.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsAlertView extends StatefulWidget {
  const NewsAlertView({super.key});

  @override
  State<NewsAlertView> createState() => _NewsAlertViewState();
}

class _NewsAlertViewState extends State<NewsAlertView> {
  @override
  Widget build(BuildContext context) {
    AlarmsViewModel alarms = Provider.of(context);

    return Column(
      children: <Widget>[
        Spacer(),
        Row(
          children: [
            const Text('🔔', style: TextStyle(fontSize: 70)),
            const Text('📰', style: TextStyle(fontSize: 150)),
            const Text('🔔', style: TextStyle(fontSize: 70)),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Row(
          children: [
            const Text("C'est l'heure des news !!",
                style: TextStyle(fontSize: 20))
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Spacer(),
        RawMaterialButton(
          onPressed: () {},
          elevation: 2.0,
          fillColor: Colors.lightBlue,
          child: Icon(
            Icons.play_arrow,
            size: 100.0,
          ),
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
        ),
        const SizedBox(height: 20),
        RawMaterialButton(
          onPressed: alarms.stopAlarms,
          elevation: 2.0,
          fillColor: Colors.red,
          child: Icon(
            Icons.alarm_off,
            size: 25.0,
          ),
          padding: EdgeInsets.all(15.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        Spacer(),
      ],
    );
  }
}
