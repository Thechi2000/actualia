import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';

class Alarms {
  bool enabled;
  int id;
  DateTime dateTime;
  String assetAudioPath;
  bool loopAudio;
  bool vibrate;
  double volume;
  double fadeDuration;
  String notificationTitle;
  String notificationBody;
  bool enableNotificationOnKill;

  Alarms({
    required this.enabled,
    required this.id,
    required this.dateTime,
    required this.assetAudioPath,
    required this.loopAudio,
    required this.vibrate,
    required this.volume,
    required this.fadeDuration,
    required this.notificationTitle,
    required this.notificationBody,
    required this.enableNotificationOnKill,
  });

  factory Alarms.defaults() {
    return Alarms(
      enabled: false,
      id: 0,
      dateTime: DateTime.now(),
      assetAudioPath: 'assets/last-transcript.mp3',
      loopAudio: false,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'This is the title',
      notificationBody: 'This is the body',
      enableNotificationOnKill: true,
    );
  }

  Future<void> setAlarm() async {
    await Alarm.init();
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      fadeDuration: fadeDuration,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      enableNotificationOnKill: enableNotificationOnKill,
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(id);
  }

  void onRingCallback() {
    void yourOnRingCallback() {
      // Do something when the alarm rings
    }

    Alarm.ringStream.stream.listen((_) => yourOnRingCallback());
  }
}
