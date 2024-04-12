import 'dart:developer';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  News? _news;
  News? get news => _news;

  Future<void> getNews(DateTime date) async {
    await fetchNews(date); // Try fetching news first

    // Check if news is still null after fetch
    if (_news == null || _news!.paragraphs.isEmpty) {
      // Check if the requested date is today
      DateTime today = DateTime.now();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        // If today, invoke transcript function to generate news
        await invokeTranscriptFunction();
        // Try fetching the news again after news generation
        await fetchNews(date);
        // Check again if news is still not fetched
        if (_news == null || _news!.paragraphs.isEmpty) {
          // Handle error if no news even after invoking transcript
          setNewsError(date, 'News generation failed and no news found.',
              'Something went wrong while generating news. Please try again later.');
        }
      } else {
        // If not today, set error news
        setNewsError(date, 'No news found for this date.',
            'There are no news for you on this date.');
      }
    }
    // If news is fetched successfully or handled by error logic, notify listeners
    notifyListeners();
  }

  Future<void> fetchNews(DateTime date) async {
    var dateString = date.toString().substring(0, 10);
    try {
      final response = await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .eq('date', dateString)
          .single();

      // Check if the response contains an error or no data was found
      if (response['error'] != null || response.isEmpty) {
        log("No news found or error: ${response['error']?.message}");
        _news =
            null; // Ensure news is null to trigger proper handling in getNews
        return;
      }

      // Parsing texts and sources assuming they are JSON encoded strings
      List<String> texts = List<String>.from(jsonDecode(response['texts']));
      List<String> sources = List<String>.from(jsonDecode(response['sources']));
      List<Paragraph> paragraphs = [];
      for (var i = 0; i < texts.length; i++) {
        paragraphs.add(Paragraph(text: texts[i], source: sources[i]));
      }

      _news = News(
        title: response['title'],
        date: response['date'],
        paragraphs: paragraphs,
      );
      notifyListeners();
    } catch (e) {
      log("Error fetching news: $e");
      _news = null; // Ensure news is null to trigger proper handling in getNews
    }
  }

  Future<void> invokeTranscriptFunction() async {
    try {
      // Placeholder for invoking a cloud function
      // This is simulated and should be replaced with actual cloud function call
      await Future.delayed(
          Duration(seconds: 5)); // Simulate cloud function delay
      log("Cloud function 'transcript' invoked successfully.");
    } catch (e) {
      log("Error invoking cloud function: $e");
      throw Exception("Failed to invoke transcript function");
    }
  }

  void setNewsError(DateTime date, String title, String message) {
    _news = News(
      date: date.toString().substring(0, 10),
      title: title,
      paragraphs: [Paragraph(text: message, source: 'System')],
    );
  }
}
