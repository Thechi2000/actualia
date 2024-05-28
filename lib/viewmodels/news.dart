import 'dart:developer';
import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

typedef Content = Either<List<News>, String>;

/// View model for managing news data.
class NewsViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  Content? _content;

  News? get news => newsList?.firstOrNull;
  List<News>? get newsList => _content?.fold((l) => l, (r) => null);
  String? get error => _content?.fold((l) => null, (r) => r);
  bool get isEmpty => newsList?.isEmpty ?? true;
  bool get isLoading => _content == null;

  @protected
  void setNews(News? news) {
    setNewsList(news != null ? [news] : []);
  }

  @protected
  void setNewsList(List<News> newsList) {
    _content = Left(newsList);
    notifyListeners();
  }

  @protected
  void setError(String error) {
    _content = Right(error);
    notifyListeners();
  }

  @protected
  NewsViewModel(this.supabase);

  /// Retrieves news for the specified date.
  ///
  /// If no news is found for the given date, it checks if the date is today.
  /// If it is today, it invokes a cloud function to generate news and fetches it again.
  /// If the news is still not found, it sets an error message.
  Future<void> getNews(DateTime date) async {
    await fetchNews(date);
    if (isEmpty) {
      DateTime today = DateTime.now();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        await generateAndGetNews();
      } else {
        setError('There are no news for you on this date.');
      }
    }
  }

  /// Fetches news for the specified date from the database.
  Future<void> fetchNews(DateTime date) async {
    // Converts time to UTC to match Supabase's instances.
    date = date.toUtc();

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
        setNewsList([]);
        return;
      }

      setNewsList([parseNews(response), ...newsList ?? []]);
    } catch (e) {
      log("Error fetching news: $e", level: Level.WARNING.value);
      setError("Unable to reach the server.");
    }
  }

  Future<void> getNewsList() async {
    try {
      var response = await fetchNewsList();

      if (response.isEmpty) {
        setNewsList([]);
      } else {
        setNewsList(response.map<News>((news) => parseNews(news)).toList());

        Future.wait(newsList!.map((e) => getAudioFile(e)))
            .whenComplete(() => notifyListeners());

        // If the date of the first news is more than 12 hours ago, call the cloud function
        if (DateTime.now()
                .difference(DateTime.parse(newsList![0].date))
                .inHours >
            12) {
          await generateAndGetNews();
        }
      }
    } catch (e) {
      log("Error fetching news list: $e", level: Level.WARNING.value);
      setError("Unable to fetch the news.");
    }
  }

  Future<void> generateAndGetNews() async {
    await invokeTranscriptFunction();

    // We only fetch one news since we already fetched the list and it was either empty or needed a single entry to be added
    await fetchNews(DateTime.now());

    if (isEmpty) {
      setError(
          'Something went wrong while generating news. Please try again later.');
    } else {
      getAudioFile(news!).whenComplete(() => notifyListeners());
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
    if (response['transcript']['totalNewsByLLM'] == "0") {
      throw Exception("The given news item has no transcript.");
    }
    List<dynamic> newsItems = response['transcript']['news'];

    List<Paragraph> paragraphs = newsItems
        .where((item) => item['transcript'] != null)
        .map((item) => Paragraph(
            transcript: item['transcript'],
            source: item['source']['name'],
            url: item['url'],
            title: item['title'],
            date: item['publishedAt'],
            content: item['content']))
        .toList();

    return News(
        title: response['title'],
        // Dates are stored in UTC timezone in the database.
        date: DateTime.parse(response['date']).toLocal().toIso8601String(),
        transcriptId: response['id'],
        audio: response['audio'],
        paragraphs: paragraphs,
        fullTranscript: response['transcript']['fullTranscript']);
  }

  /// Invokes a cloud function to generate news transcripts.
  Future<void> invokeTranscriptFunction() async {
    try {
      await supabase.functions.invoke('generate-transcript', body: {});
      log("Cloud function 'transcript' invoked successfully.",
          level: Level.INFO.value);
    } catch (e) {
      log("Error invoking cloud function: $e", level: Level.WARNING.value);
      throw Exception("Failed to invoke transcript function");
    }
  }

  // Function to get the audio file from the database
  Future<void> getAudioFile(News news) async {
    // Check for valid transcriptId
    if (news.transcriptId == -1) {
      return;
    }

    try {
      // Generate audio if not present
      news.audio ??= await generateAudio(news.transcriptId);

      // File download
      final response =
          await supabase.storage.from("audios").download(news.audio!);

      if (response.isEmpty) {
        log('Audio file not found.', level: Level.WARNING.value);
        return;
      }

      log('Audio file downloaded successfully.', level: Level.INFO.value);

      final directory = await getApplicationDocumentsDirectory();
      final transcriptsDirectory = Directory('${directory.path}/audios');

      if (!await transcriptsDirectory.exists()) {
        await transcriptsDirectory.create(recursive: true);
      }

      final file =
          File('${transcriptsDirectory.path}/${news.transcriptId}.mp3');
      await file.writeAsBytes(response);
    } catch (e) {
      log('Error downloading audio file: $e', level: Level.WARNING.value);
    }
  }

  Future<String> generateAudio(int transcriptId) async {
    try {
      final audio = await supabase.functions
          .invoke('generate-audio', body: {"transcriptId": transcriptId});

      log("Cloud function 'audio' invoked successfully.",
          level: Level.INFO.value);
      return audio.data;
    } catch (e) {
      log("Error invoking audio cloud function: $e",
          level: Level.WARNING.value);
      throw Exception("Failed to invoke audio function");
    }
  }

  Future<Source?> getAudioSource(int transcriptId) async {
    if (transcriptId == -1) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/audios/$transcriptId.mp3';

    final file = File(filePath);
    if (await file.exists()) {
      return DeviceFileSource(filePath);
    } else {
      log("Can't find audio file at $filePath", level: Level.WARNING.value);
      return null;
    }
  }
}
