// 관리 화면 틀

import 'package:flutter/material.dart';
import 'package:spin_pick/screen/user_screen.dart';
import 'package:spin_pick/screen/penalty_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '멤버'),
              Tab(text: '벌칙'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MemberScreen(),
            PenaltyScreen(),
          ],
        ),
      ),
    );
  }
}