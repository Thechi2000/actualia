import 'package:actualia/models/alarms.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmsViewModel extends ChangeNotifier {
  late final supabase;

  static int _alarmId = 1;
  bool isAlarmRinging = false;

  AlarmsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
    Alarm.ringStream.stream.listen((_) {
      print("ringStream.stream.listen callback called");
      isAlarmRinging = true;
      notifyListeners();
    });
    checkAndroidScheduleExactAlarmPermission();
  }

  Future<void> setAlarm(DateTime dateTime, String assetAudioPath,
      bool loopAudio, bool vibrate, double volume) async {
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
  }

  Future<void> stopAlarms() async {
    await Alarm.stopAll();
    isAlarmRinging = false;
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
