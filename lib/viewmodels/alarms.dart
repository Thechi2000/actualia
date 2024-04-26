import 'package:actualia/models/alarms.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmsViewModel extends ChangeNotifier {
  late final supabase;

  AlarmsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  Alarms? _alarms;

  Alarms? get alarms => _alarms;
}
