import 'dart:developer';

import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  News? _news;
  News? get news => _news;

  Future<void> fetchNews(DateTime date) async {
    var dateString = date.toString().substring(0, 10);
    try {
      final res = await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .eq('date', dateString)
          .single();

      //If pas de news pour ce jour là ET date == aujourd'hui, on appelle la fonction transcript
      //Si bon jour mais avant l'heure, dire de revenir. Si bon jour après l'heure, dire qu'il y a un problème.

      List<String> texts = List<String>.from(jsonDecode(res['texts']));
      List<String> sources = List<String>.from(jsonDecode(res['sources']));
      List<Paragraph> paragraphs = [];
      for (var i = 0; i < texts.length; i++) {
        paragraphs.add(Paragraph(text: texts[i], source: sources[i]));
      }
      /*
      final get_news = await supabase.functions
          .invoke("get_news", method: HttpMethod.post);*/

      _news = News(
        title: res['title'],
        date: res['date'],
        paragraphs: paragraphs,
      );
      notifyListeners();
    } catch (e) {
      log("Error fetching settings: $e");
      _news = News(
          date: date.toString().substring(0, 10),
          title: 'No news found for this date',
          paragraphs: [
            Paragraph(
                text:
                    'There has been an error fetching news from the database. (click me to print the error message)',
                source: e.toString())
          ]);
      notifyListeners();
      return;
    }
  }
/*
  Future<bool> pushNews(News news) async {
    print("Pushing news: $news");
    final texts = news.paragraphs.map((e) => e.text).toList();
    final sources = news.paragraphs.map((e) => e.source).toList();
    try {
      final res = await supabase.from("news").upsert({
        'user': supabase.auth.currentUser!.id,
        'date': news.date,
        'title': news.title,
        'texts': texts,
        'sources': sources,
      },);
      print("Pushed news: $res");
      return true;
    } catch (e) {
      print("Error pushing news: $e");
      log("Error pushing settings: $e");
      return false;
    }
  }*/
}
