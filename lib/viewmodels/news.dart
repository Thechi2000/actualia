import 'dart:developer';
import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// View model for managing news data.
class NewsViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  News? _news;
  News? get news => _news;
  List<News> _newsList = [];
  List<News> get newsList => _newsList;

  @protected
  void setNews(News? news) {
    _news = news;
  }

  @protected
  void setNewsList(List<News> newsList) {
    _newsList = newsList;
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
        await generateAndGetNews();
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

      _news = parseNews(response);
      notifyListeners();
    } catch (e) {
      log("Error fetching news: $e", level: Level.WARNING.value);
      _news = null;
    }
  }

  Future<void> getNewsList() async {
    try {
      var response = await fetchNewsList();

      if (response.isEmpty) {
        await generateAndGetNews();
        _newsList.insert(0, _news!);
      } else {
        _newsList = response.map<News>((news) => parseNews(news)).toList();

        //If the date of the first news is not today, call the cloud function
        if (_newsList[0].date.substring(0, 10) !=
            DateTime.now().toString().substring(0, 10)) {
          await generateAndGetNews();
          _newsList.insert(0, _news!);
        }
      }
      for (var news in _newsList) {
        //if (news.audio != null) {
        getAudioFile(news).whenComplete(() => notifyListeners());
        //}
      }
    } catch (e) {
      log("Error fetching news list: $e", level: Level.WARNING.value);
      _newsList = [];
    }
    notifyListeners();
  }

  @protected
  Future<void> generateAndGetNews() async {
    await invokeTranscriptFunction();
    await fetchNews(DateTime
        .now()); //We only fetch one news since we already fetched the list and it was either empty or needed a single entry to be added

    if (_news == null || _news!.paragraphs.isEmpty) {
      setNewsError(DateTime.now(), 'News generation failed and no news found.',
          'Something went wrong while generating news. Please try again later.');
    }
  }

  Future<List<dynamic>> fetchNewsList() async {
    return await supabase
        .from('news')
        .select()
        .eq('user', supabase.auth.currentUser!.id)
        .order('date', ascending: false) // Sorting by date descending
        .limit(10); // Limiting to 10 news items;
  }

  News parseNews(dynamic response) {
    List<dynamic> newsItems = response['transcript']['articles'];
    List<Paragraph> paragraphs = newsItems.map((item) {
      return Paragraph(
          transcript: item['transcript'],
          source: item['source']['name'],
          title: item['title'],
          date: item['publishedAt'],
          content: item['content']);
    }).toList();

    return News(
      title: response['title'],
      date: response['date'],
      transcriptID: response['id'],
      audio: response['audio'],
      paragraphs: paragraphs,
    );
  }

  /// Invokes a cloud function to generate news transcripts.
  Future<void> invokeTranscriptFunction() async {
    try {
      await supabase.functions.invoke('get-transcript');
      log("Cloud function 'transcript' invoked successfully.",
          level: Level.INFO.value);
    } catch (e) {
      log("Error invoking cloud function: $e", level: Level.WARNING.value);
      throw Exception("Failed to invoke transcript function");
    }
  }

  // Function to get the audio file from the database
  Future<Uint8List?> getAudioFile(News news) async {
    String audio = '9863869a-d0e7-4462-8738-a32395e86e87/15.mp3';
    print("audio : $audio");
    try {
      // File download
      final response = await supabase.storage.from("audios").download(audio);
      print("response : $response");

      if (response.isEmpty) {
        log('Audio file not found.', level: Level.WARNING.value);
        print("Audio file not found.");
        return null;
      }

      log('Audio file downloaded successfully.', level: Level.INFO.value);
      print("Audio file downloaded successfully.");

      final directory = await getApplicationDocumentsDirectory();
      final transcriptsDirectory = Directory('${directory.path}/transcripts');

      if (!await transcriptsDirectory.exists()) {
        await transcriptsDirectory.create(recursive: true);
        print('Directory created: ${transcriptsDirectory.path}');
      }

      final file = File('${transcriptsDirectory.path}/${news.transcriptID}');
      print('Created empty file: ${file.path}');
      await file.writeAsBytes(response);
      print('File written at: ${file.path}');

      return response;
    } catch (e) {
      log('Error downloading audio file: $e', level: Level.WARNING.value);
      print("Error downloading audio file: $e");
      return null;
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
