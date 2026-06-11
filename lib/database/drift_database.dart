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

part 'drift_database.g.dart';

// 멤버 테이블 정의
class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1)(); // 빈값 입력 방지
}

// 벌칙 테이블 정의
class Penalties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text().withLength(min: 1)(); // 빈값 입력 방지
}

// 히스토리 테이블 정의
class Histories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memberName => text()();
  TextColumn get penaltyContent => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Members, Penalties, Histories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 멤버 추가 / 삭제 / 목록 조회
  Future<int> insertMember(MembersCompanion member) => into(members).insert(member);
  Future<int> deleteMember(int id) => (delete(members)..where((t) => t.id.equals(id))).go();
  Stream<List<Member>> watchMembers() => select(members).watch();

  // 벌칙 추가 / 삭제 / 목록 조회
  Future<int> insertPenalty(PenaltiesCompanion penalty) => into(penalties).insert(penalty);
  Future<int> deletePenalty(int id) => (delete(penalties)..where((t) => t.id.equals(id))).go();
  Stream<List<Penalty>> watchPenalties() => select(penalties).watch();

  // 히스토리 목록 표시
  Stream<List<History>> watchHistories() =>
      (select(histories)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();

  // 히스토리 결과 저장
  Future<int> insertHistory(HistoriesCompanion history) => into(histories).insert(history);

  // 히스토리 전체 초기화
  Future<int> clearAllHistories() => delete(histories).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spinpick.sqlite'));
    return NativeDatabase(file);
  });
}