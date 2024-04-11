import 'dart:developer';

import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  News? _news;
  News? get news => _news;

  Future<void> fetchNews(DateTime date) async {
    var dateString = date.toString().substring(0, 10);
    try {
      print(DateTime.parse('2024-04-14').weekday);
      final res = await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .eq('date', dateString)
          .single();

      final texts = res['texts'];
      final sources = res['sources'];

      _news = News(
        title: res['title'],
        date: res['date'],
        paragraphs: List.generate(texts.length, (index) {
          return Paragraph(
            text: texts[index],
            source: sources[index],
          );
        }),
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
