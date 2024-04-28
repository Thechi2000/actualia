import 'package:actualia/models/alarms.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmsViewModel extends ChangeNotifier {
  late final supabase;

  AlarmsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  Alarms? _alarms;

  Alarms? get alarms => _alarms;

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    print('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      print('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      print(
          'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
    }
  }
}
