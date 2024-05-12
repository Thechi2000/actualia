import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  List<NewsProvider>? _newsProviders;
  List<NewsProvider>? get newsProviders => _newsProviders;

  List<(ProviderType, List<String>)> get editedProviders => _editedProviders;
  late List<(ProviderType, List<String>)> _editedProviders;

  ProvidersViewModel(this.supabase) {
    fetchNewsProviders();
  }

  void setNewsProviders(List<NewsProvider> newsProviders) {
    _newsProviders = newsProviders;
  }

  Future<bool> fetchNewsProviders() async {
    try {
      final res = await supabase
          .from('news_settings')
          .select("providers")
          .eq("created_by", supabase.auth.currentUser!.id)
          .single();

      _newsProviders = (res["providers"] as List<dynamic>)
          .map((e) => NewsProvider(url: e))
          .toList();
      _editedProviders = _newsProviders!
          .map((e) => (e.type, e.parameters.toList()))
          .toList(growable: true);

      log("fetch result: $_newsProviders", level: Level.FINEST.value);
      return true;
    } catch (e) {
      log("Could not fetch news providers: $e", level: Level.WARNING.value);
      _newsProviders = [];
      _editedProviders = [];
      return false;
    }
  }

  void updateProvidersFromEdited() {
    _newsProviders = _editedProviders
        .map((e) => NewsProvider(
            url: [e.$1.basePath, ...e.$2].where((e) => e.isNotEmpty).join("/")))
        .toList();
  }

  void addEditedProvider() {
    _editedProviders.add((ProviderType.rss, [""]));
    notifyListeners();
  }

  void removeEditedProvider(int index) {
    _editedProviders.removeAt(index);
    notifyListeners();
  }

  void updateEditedProvider(int index, ProviderType type, List<String> values) {
    _editedProviders[index] = (type, values);
    // Does not call notifyListeners() to avoid redrawing the edition widgets.
  }

  Future<bool> pushNewsProviders() async {
    try {
      await supabase
          .from("news_settings")
          .update({"providers": _newsProviders!.map((e) => e.url).toList()}).eq(
              "created_by", supabase.auth.currentUser!.id);
      return true;
    } catch (e) {
      log("Could not push news providers: $e", level: Level.WARNING.value);
      return false;
    }
  }
}
