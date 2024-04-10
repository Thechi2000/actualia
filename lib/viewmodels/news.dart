import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  late News _news;
  News get news => _news;


  Future<void> fetchNews(DateTime date) async {
    final dateString = date.toIso8601String();
    final res = await supabase
        .from('news')
        .select()
        .eq('user', supabase.auth.currentUser!.id)
        .eq('date', dateString)
        .single();
    if (res['error'] != null) {
      print("Error fetching news: ${res['error'].message}");
      return;
    }

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
  }

}
