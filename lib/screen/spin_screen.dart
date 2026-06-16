// 메인 룰렛 화면

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_pick/database/drift_database.dart';
import 'dart:math';

class SpinScreen extends StatefulWidget {
  const SpinScreen({Key? key}) : super(key: key);

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사람(왼쪽)과 벌칙(오른쪽)을 가로로 배치
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 왼쪽: 멤버 목록 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            '멤버 목록',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<Member>>(
                            stream: GetIt.I<LocalDatabase>().watchMembers(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('멤버를 추가해주세요!'));
                              }
                              return ListView(
                                children: snapshot.data!.map((member) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Chip(
                                      label: Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(member.name),
                                      ),
                                      backgroundColor: member.isSelected
                                          ? Colors.grey[300]
                                          : Colors.blue[100],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16), // 왼쪽 오른쪽 사이 간격

                  // 2. 오른쪽: 벌칙 목록 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            '벌칙 목록',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<Penalty>>(
                            stream: GetIt.I<LocalDatabase>().watchPenalties(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('벌칙을 추가해주세요!'));
                              }
                              return ListView(
                                children: snapshot.data!.map((penalty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Chip(
                                      label: Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(penalty.content),
                                      ),
                                      backgroundColor: Colors.orange[100],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 뽑기 버튼
            StreamBuilder<List<Member>>(
              stream: GetIt.I<LocalDatabase>().watchMembers(),
              builder: (context, memberSnapshot) {
                return StreamBuilder<List<Penalty>>(
                  stream: GetIt.I<LocalDatabase>().watchPenalties(),
                  builder: (context, penaltySnapshot) {
                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (memberSnapshot.hasData &&
                            memberSnapshot.data!.isNotEmpty &&
                            penaltySnapshot.hasData &&
                            penaltySnapshot.data!.isNotEmpty)
                            ? () => onSpinPressed(
                            memberSnapshot.data!, penaltySnapshot.data!)
                            : null, // 멤버나 벌칙 없으면 비활성화
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4CECE),
                        ),
                        child: const Text(
                          'SPIN!',
                          style: TextStyle(fontSize: 24, color: Color(0xFFCC2827),),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void onSpinPressed(List<Member> members, List<Penalty> penalties) async {
    final db = GetIt.I<LocalDatabase>();

    // 안걸린 멤버만 필터링
    List<Member> availableMembers =
    members.where((m) => !m.isSelected).toList();

    // 모두 걸렸으면 초기화
    if (availableMembers.isEmpty) {
      await db.resetSelected();
      availableMembers = members;
    }

    // 랜덤으로 멤버 + 벌칙 뽑기
    final random = Random();
    final selectedMember =
    availableMembers[random.nextInt(availableMembers.length)];
    final selectedPenalty = penalties[random.nextInt(penalties.length)];

    // 걸린 멤버 isSelected 업데이트
    await db.updateSelected(selectedMember.id, true);

    // 히스토리 저장
    await db.createHistory(
      HistoriesCompanion(
        memberName: Value(selectedMember.name),
        penalty: Value(selectedPenalty.content),
        date: Value(DateTime.now()),
      ),
    );

    // 결과 팝업
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 당첨!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedMember.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              selectedPenalty.content,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}