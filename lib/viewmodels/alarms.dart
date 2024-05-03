import 'dart:developer';

import 'package:actualia/models/alarms.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmsViewModel extends ChangeNotifier {
  late final supabase;

  static int _alarmId = 1;
  bool isAlarmRinging = false;
  bool isAlarmActive = false;

  AlarmSettings? get alarm => Alarm.getAlarm(_alarmId);
  bool get isAlarmSet => Alarm.getAlarm(_alarmId) != null;

  AlarmsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
    Alarm.ringStream.stream.listen((_) {
      print("ringStream.stream.listen callback called");
      isAlarmRinging = true;
      isAlarmActive = true;
      notifyListeners();
    });
    checkAndroidScheduleExactAlarmPermission();
  }

  Future<void> setAlarm(DateTime dateTime, String assetAudioPath,
      bool loopAudio, bool vibrate, double volume, int? settingsId) async {
    final settings = AlarmSettings(
        id: _alarmId,
        dateTime: dateTime,
        assetAudioPath: assetAudioPath,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: volume,
        fadeDuration: 3.0,
        notificationTitle: 'News Alert !',
        notificationBody: 'Your customized News Alert is ready !',
        enableNotificationOnKill: true,
        androidFullScreenIntent: true);
    print("Alarm set with settings : $settings");
    await Alarm.set(alarmSettings: settings);

    if (settingsId != null) {
      final timetz =
          "${dateTime.hour}:${dateTime.minute}:${dateTime.second}+${dateTime.timeZoneOffset.inHours}";
      try {
        await supabase.from("alarms").upsert({
          'created_by': supabase.auth.currentUser!.id,
          'timetz': timetz,
          'transcript_settings_id': settingsId
        }, onConflict: "created_by");
        print("Alarm pushed on supabase");
      } catch (e) {
        //log("Error pushing alarm: $e", level: Level.WARNING.value);
        print("Error pushing alarm: $e");
      }
    }
  }

  Future<void> unsetAlarm() async {
    await Alarm.stop(_alarmId);
  }

  Future<void> stopAlarms() async {
    await Alarm.stopAll();
    isAlarmRinging = false;
    notifyListeners();
  }

  void dismissAlarm() {
    isAlarmActive = false;
    notifyListeners();
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
    print('Schedule exact alarm permission: $scheduleExactAlarmStatus.');
    if (!scheduleExactAlarmStatus.isGranted) {
      print('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      print(
          'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
    }
    final notificationStatus = await Permission.notification.status;
    print('Notification permission: $notificationStatus.');
    if (!notificationStatus.isGranted) {
      print('Requesting notification permission...');
      final res = await Permission.notification.request();
      print('Notification permission ${res.isGranted ? '' : 'not'} granted.');
    }
  }
}
