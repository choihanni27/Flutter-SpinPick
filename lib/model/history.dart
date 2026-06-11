// 히스토리 테이블 구조 정의
import 'package:drift/drift.dart';
class Histories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memberName => text()();
  TextColumn get penalty => text()();
  DateTimeColumn get date => dateTime()();
}