import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  late List<NewsProvider> _newsProviders;

  ProvidersViewModel(this.supabase);

  List<NewsProvider> get newsProviders => _newsProviders;
  void setNewsProviders(List<NewsProvider> newsProviders) {
    _newsProviders = newsProviders;
  }

  Future<bool> fetchNewsProviders() async {
    try {
      final res = await supabase
          .from('news_providers')
          .select()
          .eq("created_by", supabase.auth.currentUser!.id)
          .single();
      List<dynamic> temp = jsonDecode(res['providers']);
      _newsProviders = temp.map((e) => NewsProvider.deserialize(e)!).toList();
      return true;
    } catch (e) {
      debugPrint("ERROR: $e");
      log("Error when fetching news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      return false;
    }
  }

  Future<bool> pushNewsProviders() async {
    try {
      final List<dynamic> toPush =
          _newsProviders.map((e) => e.serialize()).toList();
      await supabase.from("news_providers").upsert({
        "created_by": supabase.auth.currentUser!.id,
        "providers": toPush,
      }, onConflict: "created_by");
      return true;
    } catch (e) {
      log("Error when pushing news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      return false;
    }
  }
}
