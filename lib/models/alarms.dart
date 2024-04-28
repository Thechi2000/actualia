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
}

/* final alarmSettings = AlarmSettings(
  id: 42,
  dateTime: dateTime,
  assetAudioPath: 'assets/alarm.mp3',
  loopAudio: true,
  vibrate: true,
  volume: 0.8,
  fadeDuration: 3.0,
  notificationTitle: 'This is the title',
  notificationBody: 'This is the body',
  enableNotificationOnKill: true,
); */
