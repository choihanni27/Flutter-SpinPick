// main.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// 상대 경로를 사용하여 안전하게 연동
import './database/drift_database.dart';
import './screen/user_screen.dart';
import './screen/penalty_screen.dart';
import './screen/history_screen.dart';

void main() async {
  // Flutter 프레임워크 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // AppDatabase 인스턴스 생성 및 GetIt 싱글톤 등록
  final database = AppDatabase();
  GetIt.I.registerSingleton<AppDatabase>(database);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainTestNavigationScreen(),
    ),
  );
}

/// 지금까지 만든 3개의 화면을 하단 탭으로 이동하며 테스트할 수 있는 내비게이션 내장 화면
class MainTestNavigationScreen extends StatefulWidget {
  const MainTestNavigationScreen({super.key});

  @override
  State<MainTestNavigationScreen> createState() => _MainTestNavigationScreenState();
}

class _MainTestNavigationScreenState extends State<MainTestNavigationScreen> {
  int _selectedIndex = 0;
  late final AppDatabase _database;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _database = GetIt.I<AppDatabase>();

    _screens = [
      MemberScreen(database: _database),
      PenaltyScreen(database: _database),
      HistoryScreen(database: _database),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '멤버 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: '벌칙 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
          ),
        ],
      ),
    );
  }
}