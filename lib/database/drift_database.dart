// DB 핵심 파

// 테이블 생성
// 데이터 저장
// 데이터 삭제
// 데이터 조회

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:spin_pick/model/member.dart';
import 'package:spin_pick/model/penalty.dart';
import 'package:spin_pick/model/history.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [Members, Penalties, Histories])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // 멤버
  Stream<List<Member>> watchMembers() => select(members).watch();
  Future<int> createMember(MembersCompanion data) => into(members).insert(data);
  Future<int> removeMember(int id) => (delete(members)..where((t) => t.id.equals(id))).go();
  Future updateSelected(int id, bool isSelected) => (update(members)..where((t) => t.id.equals(id))).write(MembersCompanion(isSelected: Value(isSelected)));
  Future resetSelected() => (update(members)).write(MembersCompanion(isSelected: Value(false)));

  // 벌칙
  Stream<List<Penalty>> watchPenalties() => select(penalties).watch();
  Future<int> createPenalty(PenaltiesCompanion data) => into(penalties).insert(data);
  Future<int> removePenalty(int id) => (delete(penalties)..where((t) => t.id.equals(id))).go();

  // 히스토리
  Stream<List<History>> watchHistories() => select(histories).watch();
  Future<int> createHistory(HistoriesCompanion data) => into(histories).insert(data);
  Future<int> clearHistories() => delete(histories).go();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationCacheDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}