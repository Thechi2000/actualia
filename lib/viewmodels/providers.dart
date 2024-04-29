import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  List<NewsProvider>? _newsProviders;

  ProvidersViewModel(this.supabase) {
    fetchNewsProviders();
  }

  List<NewsProvider>? get newsProviders => _newsProviders;
  void setNewsProviders(List<NewsProvider> newsProviders) {
    _newsProviders = newsProviders;
  }

  List<String> providersToString(List<NewsProvider> providers) {
    return providers.map((e) => e.displayName()).toList();
  }

  List<NewsProvider> stringToProviders(List<String> names) {
    return names.map((e) {
      switch (e) {
        case "gnews":
          return GNewsProvider();
        default:
          log("Unknown provider name: $e", level: Level.WARNING.value);
          return GNewsProvider();
      }
    }).toList();
  }

  Future<bool> fetchNewsProviders() async {
    //todo fix
    try {
      final res = await supabase
          .from('news_providers')
          .select()
          .eq("created_by", supabase.auth.currentUser!.id)
          .maybeSingle();
      debugPrint("providers: ${res?['providers']}");
      final temp = List.from(jsonDecode(res?['providers']));
      _newsProviders = temp.map((e) => NewsProvider.deserialize(e)!).toList();
      return true;
    } catch (e) {
      log("Error when fetching news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      _newsProviders = [];
      debugPrint("_newsProviders initialized: $_newsProviders");
      return false;
    }
  }

  Future<bool> pushNewsProviders() async {
    try {
      final List<dynamic>? toPush =
          _newsProviders?.map((e) => e.serialize()).toList();
      await supabase.from("news_providers").upsert({
        "created_by": supabase.auth.currentUser!.id,
        "type": toPush,
      }, onConflict: "created_by");
      return true;
    } catch (e) {
      log("Error when pushing news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      return false;
    }
  }
}
