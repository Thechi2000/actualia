import 'package:actualia/models/news.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => const User(
      id: "1234",
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: "aud",
      createdAt: "createdAt");
}

class FakeFailingQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    final Map<String, dynamic> dict = values as Map<String, dynamic>;

    expect(dict["created_by"], equals("1234"));
    expect(listEquals(dict["cities"], []), isTrue);
    expect(listEquals(dict["countries"], []), isTrue);
    expect(listEquals(dict["interests"], ["Biology"]), isTrue);
    expect(dict["wantsCities"], isFalse);
    expect(dict["wantsCountries"], isFalse);
    expect(dict["wantsInterests"], isTrue);

    throw UnimplementedError();
  }
}

class FakeFailingFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post}) {
    throw UnimplementedError();
  }
}

class FakeFailingSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    expect(table, equals("news_settings"));
    return FakeFailingQueryBuilder();
  }

  @override
  GoTrueClient get auth => FakeGoTrueClient();

  @override
  FunctionsClient get functions => FakeFailingFunctionsClient();
}

class FakeFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post}) {
    expect(functionName, equals('get-transcript'));
    expect(body, isNull);
    expect(method, equals(HttpMethod.post));

    return Future.value(FunctionResponse(status: 200));
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  FunctionsClient get functions => FakeFunctionsClient();
}

class AlreadyExistingNewsVM extends NewsViewModel {
  AlreadyExistingNewsVM(super.supabase);

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptID: -1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content")
        ]));
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() {
    fail("invokeTranscriptFunction should not be called");
  }
}

class NonExistingNewsVM extends NewsViewModel {
  bool invokedTranscriptFunction = false;

  NonExistingNewsVM() : super(FakeSupabaseClient());

  @override
  Future<void> fetchNews(DateTime date) {
    if (invokedTranscriptFunction) {
      setNews(News(
          date: DateTime.now().toIso8601String(),
          title: "News",
          transcriptID: -1,
          audio: null,
          paragraphs: [
            Paragraph(
                transcript: "text",
                source: "source",
                title: "title",
                date: "12-04-2024",
                content: "content")
          ]));
    } else {
      setNews(null);
    }
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() async {
    invokedTranscriptFunction = true;
  }
}

class NeverExistingNewsVM extends NewsViewModel {
  NeverExistingNewsVM() : super(FakeSupabaseClient());

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(null);
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() async {}
}

void main() {
  test("get-transcript failure is reported", () async {
    NewsViewModel vm = NewsViewModel(FakeFailingSupabaseClient());
    bool hasThrown = false;

    try {
      await vm.invokeTranscriptFunction();
    } catch (e) {
      hasThrown = true;
    }

    expect(hasThrown, isTrue);
  });

  test("correctly invokes cloud function", () async {
    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());
    await vm.invokeTranscriptFunction();
  });

  test('database failure is handled', () async {
    NewsViewModel vm = NewsViewModel(FakeFailingSupabaseClient());
    await vm.fetchNews(DateTime.now());
    expect(vm.news, isNull);
  });

  test('already existing news are correctly fetched', () async {
    NewsViewModel vm = AlreadyExistingNewsVM(FakeSupabaseClient());
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
  });

  test('non existing news are correctly generated', () async {
    NonExistingNewsVM vm = NonExistingNewsVM();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
    expect(vm.invokedTranscriptFunction, isTrue);
  });

  test('non existing news are correctly generated', () async {
    NonExistingNewsVM vm = NonExistingNewsVM();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
    expect(vm.invokedTranscriptFunction, isTrue);
  });

  test('getNews with invalid date reports error', () async {
    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());
    await vm.getNews(DateTime.fromMicrosecondsSinceEpoch(0));
    expect(vm.news?.title, equals("No news found for this date."));
  });

  test('getNews with non working EF reports error', () async {
    NewsViewModel vm = NeverExistingNewsVM();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News generation failed and no news found."));
  });
}
