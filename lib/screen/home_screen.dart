// 홈 화면

// 랜덤 매칭 버튼
// 결과 카드 출력
// 참가자/벌칙 보여주기
// 랜덤 결과 실행

import 'package:flutter/material.dart';
import 'package:spin_pick/screen/spin_screen.dart';
import 'package:spin_pick/screen/management_screen.dart';
import 'package:spin_pick/screen/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // 현재 선택된 탭
  // 0 = 룰렛, 1 = 관리, 2 = 히스토리

  // 3개 화면
  final List<Widget> screens = [
    SpinScreen(),
    ManagementScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex], // 현재 탭에 맞는 화면 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedLabelStyle: TextStyle(fontFamily: 'esamanru OTF Bold'),
        unselectedLabelStyle: TextStyle(fontFamily: 'esamanru OTF Bold'),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '룰렛',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '관리',
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