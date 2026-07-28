import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pair => text()();
  RealColumn get price => real()();
  TextColumn get signal => text()();
  RealColumn get confidence => real()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [HistoryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<HistoryEntry>> getAllHistory() => select(historyEntries).get();

  Future<int> insertHistory(HistoryEntriesCompanion entry) => into(historyEntries).insert(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tradevision.sqlite'));
    return NativeDatabase(file);
  });
}
