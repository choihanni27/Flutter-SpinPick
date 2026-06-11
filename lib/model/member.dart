// 멤버 테이블 구조 정의
import 'package:drift/drift.dart';
class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();
}