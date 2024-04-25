import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Map<String, dynamic> selection;

  FakePostgrestFilterBuilder([this.selection = const {}]);

  @override
  FakePostgrestFilterBuilder<T> eq(String field, Object val) {
    Map<String, dynamic> newSelection = selection;
    newSelection
        .removeWhere((key, value) => key == field && value == val as dynamic);
    debugPrint("bob eq");
    return FakePostgrestFilterBuilder<T>(newSelection);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    debugPrint("bob single");
    return FakePostgrestFilterBuilder(selection);
  }
}

class FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final Map<String, dynamic>? tableContent;
  final String tableName;
  final FakeDB? db;

  FakeQueryBuilder(
      {this.tableContent = const {}, this.tableName = "", this.db});

  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    Map<String, dynamic> newTableContent = tableContent!;
    newTableContent.addAll(values as Map<String, dynamic>);
    db?.setTable(tableName: tableName, tableContent: newTableContent);
    return FakePostgrestFilterBuilder(newTableContent);
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String s = ""]) {
    return FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
        tableContent!);
  }
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => const User(
      id: "1234",
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: "aud",
      createdAt: "createdAt");
}

class FakeDB extends Fake implements SupabaseClient {
  Map<String, Map<String, dynamic>> _tables;

  FakeDB([this._tables = const <String, Map<String, dynamic>>{}]);

  Map get tables => _tables;
  void setTable(
          {Map<String, dynamic> tableContent = const {},
          String tableName = ""}) =>
      _tables[tableName] = tableContent;

  @override
  SupabaseQueryBuilder from(String table) {
    return FakeQueryBuilder(
        tableName: table, tableContent: _tables[table], db: this);
  }

  @override
  GoTrueClient get auth {
    return FakeGoTrueClient();
  }
}

void main() {
  test("push work as intended", () async {
    List<NewsProvider> toPush = [
      GNewsProvider(),
      RSSFeedProvider(url: "https://dummy.dummy.com")
    ];
    FakeDB db = FakeDB({"news_providers": {}});
    ProvidersViewModel vm = ProvidersViewModel(db);
    vm.setNewsProviders(toPush);
    await vm.pushNewsProviders();

    expect(db.tables["news_providers"]["providers"], [
      {"type": "gnews"},
      {"type": "rss", "url": "https://dummy.dummy.com"}
    ]);
  });

  //todo le fake est pas assez élaborer pour gerer le fetch sans throw d'erreur
  // test("fetch work as intended", () async {
  //   FakeDB db = FakeDB({
  //     "news_providers": {
  //       "created_by": "1234",
  //       "providers": [
  //         {"type": "rss", "url": "https://dummy.com"},
  //         {"type": "gnews"}
  //       ]
  //     }
  //   });
  //   ProvidersViewModel vm = ProvidersViewModel(db);
  //   await vm.fetchNewsProviders();
  //   List<NewsProvider> received = vm.newsProviders;
  //   expect(received, [RSSFeedProvider(url: "https://dummy.com"), GNewsProvider()]);
  // });
}
