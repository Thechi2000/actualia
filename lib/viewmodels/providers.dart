import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  List<(NewsProvider, String)>? _newsProviders;

  ProvidersViewModel(this.supabase) {
    fetchNewsProviders();
  }

  List<(NewsProvider, String)>? get newsProviders => _newsProviders;
  void setNewsProviders(List<(NewsProvider, String)> newsProviders) {
    _newsProviders = newsProviders;
  }

  Future<bool> fetchNewsProviders() async {
    try {
      final res = await supabase
          .from('news_settings')
          .select("providers")
          .eq("created_by", supabase.auth.currentUser!.id)
          .single();

      _newsProviders = res["providers"];
      log("fetch result: $_newsProviders",
          name: "DEBUG", level: Level.WARNING.value);
      return true;
    } catch (e) {
      log("Could not fetch news providers: $e", level: Level.WARNING.value);
      _newsProviders = [];
      return false;
    }
  }

  Future<bool> pushNewsProviders() async {
    try {
      await supabase
          .from("news_settings")
          .update({"providers": _newsProviders!.map((e) => e.$1.url).toList()});
      return true;
    } catch (e) {
      log("Could not push news providers: $e", level: Level.WARNING.value);
      return false;
    }
  }
}
