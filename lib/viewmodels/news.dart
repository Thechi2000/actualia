import 'dart:developer';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';

/// View model for managing news data.
class NewsViewModel extends ChangeNotifier {
  late final supabase;
  News? _news;
  News? get news => _news;

  @protected
  void setNews(News? news) {
    _news = news;
  }

  NewsViewModel(this.supabase);

  /// Retrieves news for the specified date.
  ///
  /// If no news is found for the given date, it checks if the date is today.
  /// If it is today, it invokes a cloud function to generate news and fetches it again.
  /// If the news is still not found, it sets an error message.
  Future<void> getNews(DateTime date) async {
    await fetchNews(date);

    if (_news == null || _news!.paragraphs.isEmpty) {
      DateTime today = DateTime.now();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        await invokeTranscriptFunction();
        await fetchNews(date);
        if (_news == null || _news!.paragraphs.isEmpty) {
          setNewsError(date, 'News generation failed and no news found.',
              'Something went wrong while generating news. Please try again later.');
        }
      } else {
        setNewsError(date, 'No news found for this date.',
            'There are no news for you on this date.');
      }
    }
    notifyListeners();
  }

  /// Fetches news for the specified date from the database.
  Future<void> fetchNews(DateTime date) async {
    String dayStart =
        DateTime(date.year, date.month, date.day).toIso8601String();
    String nextDayStart =
        DateTime(date.year, date.month, date.day + 1).toIso8601String();
    try {
      var supabaseResponse = await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .gte('date', dayStart)
          .lt('date', nextDayStart)
          .order('date', ascending: false);
      final response = supabaseResponse.isEmpty ? {} : supabaseResponse.first;

      if (response['error'] != null || response.isEmpty) {
        _news = null;
        return;
      }

      List<dynamic> newsItems = response['transcript']['articles'];
      List<Paragraph> paragraphs = newsItems.map((item) {
        return Paragraph(
            transcript: item['transcript'],
            source: item['source']['name'],
            title: item['title'],
            date: item['publishedAt'],
            content: item['content']);
      }).toList();

      _news = News(
        title: response['title'],
        date: response['date'],
        transcriptID: response['id'],
        audio: response['audio'],
        paragraphs: paragraphs,
      );
      notifyListeners();
    } catch (e) {
      log("Error fetching news: $e");
      _news = null;
    }
  }

  /// Invokes a cloud function to generate news transcripts.
  Future<void> invokeTranscriptFunction() async {
    try {
      await supabase.functions.invoke('get-transcript');
      log("Cloud function 'transcript' invoked successfully.");
    } catch (e) {
      print("Error invoking cloud function: $e");
      throw Exception("Failed to invoke transcript function");
    }
  }

  /// Sets an error message for the news.
  void setNewsError(DateTime date, String title, String message) {
    _news = News(
      date: date.toString().substring(0, 10),
      title: title,
      transcriptID: -1,
      audio: null,
      paragraphs: [
        Paragraph(
            transcript: message,
            source: 'System',
            title: '',
            date: '',
            content: '')
      ],
    );
  }
}
