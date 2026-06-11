// 벌칙 테이블 구조 정의
import 'package:drift/drift.dart';
class Penalties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
}