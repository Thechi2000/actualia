import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsSettingsModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  NewsSettingsModel() {
    fetchSettings();
  }

  String? settings;

  Future<void> fetchSettings() async {
    final res = await supabase.from("news_settings").select().execute();
    if (res.error != null) {
      print('Error: ${res.error!.message}');
      return;
    }
    settings = res.data.toString();
    notifyListeners();
  }

  Future<bool> pushSettings(String settings) async {
    final res = await supabase.functions.invoke('hello', body: {'foo': 'baa'});
    if (res.error != null) {
      print('Error: ${res.error!.message}');
      return false;
    }
    return res.data != null;
  }
}
