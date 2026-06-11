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
        title: Text(
          'SpinPick 🎰',
          style: TextStyle(fontFamily: 'esamanru OTF Bold'),),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 멤버 목록
            StreamBuilder<List<Member>>(
              stream: GetIt.I<LocalDatabase>().watchMembers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('멤버를 추가해주세요!');
                }
                return Wrap(
                  spacing: 8,
                  children: snapshot.data!.map((member) {
                    return Chip(
                      label: Text(member.name),
                      backgroundColor: member.isSelected
                          ? Colors.grey[300]  // 이미 걸린 사람 회색
                          : Colors.blue[100], // 안걸린 사람 파란색
                    );
                  }).toList(),
                );
              },
            ),

            Spacer(),

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
                        child: Text(
                          'SPIN! 🎲',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 32),
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
        title: Text('🎉 당첨!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedMember.name,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              selectedPenalty.content,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}