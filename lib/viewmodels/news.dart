import 'dart:convert';
import 'dart:developer';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// View model for managing news data.
class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  News? _news;
  News? get news => _news;

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
    try {
      var supabaseResponse = (await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .order('date', ascending: false));
      final response = supabaseResponse.isEmpty ? {} : supabaseResponse.first;

      if (response['error'] != null || response.isEmpty) {
        _news = null;
        return;
      }

      List<dynamic> newsItems = response['transcript']['articles'];
      List<Paragraph> paragraphs = newsItems.map((item) {
        return Paragraph(text: item['transcript'], source: item['url']);
      }).toList();

      _news = News(
        title: response['title'],
        date: response['date'],
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
      paragraphs: [Paragraph(text: message, source: 'System')],
    );
  }
}
