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

      // If there is no news for this day AND date == today, call the transcript function
      // If it's the right day but before the time, tell them to come back. If it's the right day after the time, say there is a problem.

      List<String> texts = List<String>.from(jsonDecode(res['texts']));
      List<String> sources = List<String>.from(jsonDecode(res['sources']));
      List<Paragraph> paragraphs = [];
      for (var i = 0; i < texts.length; i++) {
        paragraphs.add(Paragraph(text: texts[i], source: sources[i]));
      }
      //TODO : Implement the edge function call
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
}
