import 'dart:async';
import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeDeletePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final FakeDB db;
  final T? selection;

  FakeDeletePostgrestFilterBuilder({required this.db, this.selection});

  @override
  Future<Table> then<Table>(FutureOr<Table> Function(T t) func,
      {Function? onError}) async {
    try {
      return func(selection as T);
    } catch (e) {
      debugPrint("[ERROR] in then: $e");
      return Future.value(null);
    }
  }

  @override
  FakePostgrestFilterBuilder<T> eq(String field, Object val) {
    debugPrint("[DEBUG] call to equal");
    T newSelection = (selection == null
        ? db.getRows(column: field, equal: val) ?? []
        : db.getRowsFromTable(
                table: selection! as Table, col: field, equal: val) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $field and $val has been found, or parameter are invalid");
    }
    db.setProvidersTable(
        table: db
                .getRows()
                ?.where((row) => !(newSelection as Table).contains(row))
                .toList() ??
            []);
    return FakePostgrestFilterBuilder<T>(
        providerDB: db, selection: newSelection);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final FakeDB providerDB;
  final T? selection;

  FakePostgrestFilterBuilder({required this.providerDB, this.selection});

  @override
  Future<Table> then<Table>(FutureOr<Table> Function(T t) func,
      {Function? onError}) async {
    try {
      return func(selection as T);
    } catch (e) {
      debugPrint("[ERROR] in then: $e");
      return Future.value(null);
    }
  }

  @override
  FakePostgrestFilterBuilder<T> eq(String field, Object val) {
    T newSelection = (selection == null
        ? providerDB.getRows(column: field, equal: val) ?? []
        : providerDB.getRowsFromTable(
                table: selection! as Table, col: field, equal: val) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $field and $val has been found, or parameter are invalid");
    }
    return FakePostgrestFilterBuilder<T>(
        providerDB: providerDB, selection: newSelection);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    if (selection == null) {
      debugPrint("Nothing to select from");
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    } else if ((selection! as Table).length > 1) {
      debugPrint("More than one element in selection");
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    } else {
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    }
  }
}

class FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final Table table;
  final FakeDB db;

  FakeQueryBuilder({required this.table, required this.db});

  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    debugPrint("[DEBUG] call to upsert");
    Table newTable = table.toList();
    Table val;
    try {
      val = values as Table;
    } catch (e) {
      val = [values as Row];
    }
    newTable.addAll(val);
    db.setProvidersTable(table: newTable);
    return FakePostgrestFilterBuilder(providerDB: db);
  }

  @override
  PostgrestFilterBuilder<Table> select([String s = ""]) {
    return FakePostgrestFilterBuilder<Table>(providerDB: db, selection: table);
  }

  @override
  PostgrestFilterBuilder<Table> delete() {
    debugPrint("[DEBUG] call to delete");
    return FakeDeletePostgrestFilterBuilder(db: db, selection: table);
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

typedef Row = Map<String, dynamic>;
typedef Table = List<Row>;

class FakeDB extends Fake implements SupabaseClient {
  Table _providersTables;

  FakeDB([this._providersTables = const []]);

  Table get providersTable => _providersTables;
  void setProvidersTable({required Table table}) => _providersTables = table;

  void addRow(Row row) {
    _providersTables.add(row);
  }

  Table? getRowsFromTable({required Table table, String? col, Object? equal}) {
    debugPrint("[DEBUG] get from table: $table");
    return FakeDB(table).getRows(column: col, equal: equal);
  }

  Table? getRows({String? column, Object? equal}) {
    if (column == null) {
      debugPrint("[DEBUG] get row column null, return: $_providersTables");
      return _providersTables;
    } else if (equal != null) {
      debugPrint("[DEBUG] get row equal null");
      bool columnExist = providersTable.isEmpty
          ? false
          : providersTable[0].containsKey(column);
      if (!columnExist) {
        debugPrint("$column does not exist in table");
        return null;
      }
      Table res = [];
      for (var row in _providersTables) {
        if (row.containsKey(column) && row[column] == equal) {
          res.add(row);
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
    return FakeQueryBuilder(table: _providersTables, db: this);
  }

  @override
  GoTrueClient get auth {
    return FakeGoTrueClient();
  }
}

void main() {
  test("push work as intended for one row and empty db", () async {
    List<NewsProvider> toPush = [RSSFeedProvider(url: "https://dummy.com")];
    FakeDB db = FakeDB();
    ProvidersViewModel vm = ProvidersViewModel(db);
    vm.setNewsProviders(toPush.map((e) => (e, e.displayName())).toList());
    await vm.pushNewsProviders();

    expect(
        db.providersTable,
        equals([
          {
            "created_by": "1234",
            "type": {"type": "rss", "url": "https://dummy.com"}
          }
        ]));
  });

  test("push work as intended for one row and non empty db", () async {
    List<NewsProvider> toPush = [RSSFeedProvider(url: "https://dummy.com")];
    FakeDB db = FakeDB([
      {
        "created_by": "1234",
        "type": {"type": "gnews"}
      },
      {
        "created_by": "4321",
        "type": {"type": "rss", "url": "dummy"}
      },
    ]);
    ProvidersViewModel vm = ProvidersViewModel(db);
    vm.setNewsProviders(toPush.map((e) => (e, e.displayName())).toList());
    await vm.pushNewsProviders();

    expect(
        db.providersTable,
        equals([
          {
            "created_by": "4321",
            "type": {"type": "rss", "url": "dummy"}
          },
          {
            "created_by": "1234",
            "type": {"type": "rss", "url": "https://dummy.com"}
          }
        ]));
  });

  test("push work as intended for multiple row", () async {
    List<NewsProvider> toPush = [
      RSSFeedProvider(url: "https://dummy.com"),
      GNewsProvider(),
      RSSFeedProvider(url: "https://dummy2.com")
    ];
    FakeDB db = FakeDB();
    ProvidersViewModel vm = ProvidersViewModel(db);
    vm.setNewsProviders(toPush.map((e) => (e, e.displayName())).toList());
    await vm.pushNewsProviders();

    expect(
        db.providersTable,
        equals([
          {
            "created_by": "1234",
            "type": {"type": "rss", "url": "https://dummy.com"}
          },
          {
            "created_by": "1234",
            "type": {"type": "gnews"}
          },
          {
            "created_by": "1234",
            "type": {"type": "rss", "url": "https://dummy2.com"}
          }
        ]));
  });

  test("fetch work as intended for one row", () async {
    FakeDB providersDb = FakeDB([
      {
        "created_by": "1234",
        "type": {"type": "gnews"}
      }
    ]);
    ProvidersViewModel vm = ProvidersViewModel(providersDb);
    await vm.fetchNewsProviders();
    List<(NewsProvider, String)>? received = vm.newsProviders;
    expect(received.runtimeType, equals(List<(NewsProvider, String)>));
    expect(received!.length, equals(1));
    expect(received[0].$1.runtimeType, equals(GNewsProvider));
  });

  test("fetch work as intended for empty providers", () async {
    FakeDB providersDb = FakeDB();
    ProvidersViewModel vm = ProvidersViewModel(providersDb);
    await vm.fetchNewsProviders();
    List<(NewsProvider, String)>? res = vm.newsProviders;
    expect(res!.length, equals(0));
    expect(res, equals([]));
  });

  test("fetch work as intended when user has no provider registered", () async {
    FakeDB providersDb = FakeDB([
      {
        "created_by": "4321",
        "type": {"type": "gnews"}
      }
    ]);
    ProvidersViewModel vm = ProvidersViewModel(providersDb);
    await vm.fetchNewsProviders();
    List<(NewsProvider, String)>? res = vm.newsProviders;
    expect(res!.length, equals(0));
    expect(res, equals([]));
  });

  test("fetch work as intended when user has multiple providers", () async {
    FakeDB providersDb = FakeDB([
      {
        "created_by": "1234",
        "type": {"type": "gnews"}
      },
      {
        "created_by": "1234",
        "type": {"type": "rss", "url": "https://dummy.com"}
      },
      {
        "created_by": "4321",
        "type": {"type": "rss", "url": "dummy2"}
      },
    ]);
    ProvidersViewModel vm = ProvidersViewModel(providersDb);
    await vm.fetchNewsProviders();
    List<(NewsProvider, String)>? received = vm.newsProviders;
    expect(received.runtimeType, equals(List<(NewsProvider, String)>));
    expect(received!.length, equals(2));
    expect(received[0].$1.runtimeType, equals(GNewsProvider));
    expect(received[1].$1.runtimeType, equals(RSSFeedProvider));
  });
}
