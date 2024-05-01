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
  final Table? table;
  final FakeDB? db;

  FakeQueryBuilder({this.table, this.db});

  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    Table newTable = table!;
    newTable.addAll(values as Table);
    db?.setProvidersTable(table: newTable);
    return FakePostgrestFilterBuilder(newTable);
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

typedef Row = List<Map<String, dynamic>>;
typedef Table = List<Row>;

class FakeDB extends Fake implements SupabaseClient {
  Table _providersTables;

  FakeDB([this._providersTables = const []]);

  Table get providersTable => _providersTables;
  void setProvidersTable({required Table table}) => _providersTables = table;

  void addRow(Row row) {
    _providersTables.add(row);
  }

  Table? getRows({String? column, Object? equal}) {
    if (column == null) {
      return _providersTables;
    } else if (equal != null) {
      bool columnExist = false;
      for (var m in _providersTables[0]) {
        if (m.containsKey(column)) {
          columnExist = true;
        }
      }
      if (!columnExist) {
        debugPrint("$column does not exist in table");
        return null;
      }
      List<List<Map<String, dynamic>>> res = [];
      for (var row in _providersTables) {
        for (var m in row) {
          if (m.containsKey(column) && m[column] == equal) {
            res.add(row);
          }
        }
      }
      return res;
    } else {
      debugPrint(
          "If column not null, then equal should not be null, equal is: $equal");
      return null;
    }
  }

  @override
  SupabaseQueryBuilder from(String table) {
    return FakeQueryBuilder(
        tableName: table, tableContent: _providersTables, db: this);
  }

  @override
  GoTrueClient get auth {
    return FakeGoTrueClient();
  }
}

void main() {
  // test("push work as intended", () async {
  //   List<NewsProvider> toPush = [
  //     GNewsProvider(),
  //     RSSFeedProvider(url: "https://dummy.dummy.com")
  //   ];
  //   FakeDB db = FakeDB({"news_providers": {}});
  //   ProvidersViewModel vm = ProvidersViewModel(db);
  //   vm.setNewsProviders(toPush);
  //   await vm.pushNewsProviders();
  //
  //   expect(db.tables["news_providers"]["providers"], [
  //     {"type": "gnews"},
  //     {"type": "rss", "url": "https://dummy.dummy.com"}
  //   ]);
  // });

  test("fetch work as intended", () async {
    FakeDB providersDb = FakeDB();
    ProvidersViewModel vm = ProvidersViewModel(providersDb);
    await vm.fetchNewsProviders();
    List<NewsProvider> received = vm.newsProviders;
    expect(
        received, [RSSFeedProvider(url: "https://dummy.com"), GNewsProvider()]);
  });
}
