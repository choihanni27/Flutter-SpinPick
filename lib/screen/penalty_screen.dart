// 벌칙 관리 화면.

// 벌칙 추가
// 벌칙 삭제
// 벌칙 목록 관리
// lib/screen/penalty_screen.dart

import 'package:flutter/material.dart';
import '../database/drift_database.dart';
import '../component/penalty_card.dart';

class PenaltyScreen extends StatefulWidget {
  final AppDatabase database;

  const PenaltyScreen({
    super.key,
    required this.database,
  });

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  final TextEditingController _penaltyController = TextEditingController();

  // 벌칙 추가
  void _addPenalty() async {
    final content = _penaltyController.text.trim();

    if (content.isEmpty) { // 빈 값
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('벌칙 내용을 입력해 주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await widget.database.insertPenalty(
      PenaltiesCompanion.insert(content: content),
    );

    _penaltyController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  // 벌칙 삭제 확인 창
  void _deletePenalty(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('벌칙 삭제'),
        content: const Text('정말로 이 벌칙을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await widget.database.deletePenalty(id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _penaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('벌칙 관리'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 입력
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _penaltyController,
                    decoration: const InputDecoration(
                      hintText: '새로운 벌칙 내용 입력',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _addPenalty(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addPenalty,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
          // 벌칙 리스트
          Expanded(
            child: StreamBuilder<List<Penalty>>(
              stream: widget.database.watchPenalties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final penalties = snapshot.data ?? [];

                if (penalties.isEmpty) {
                  return const Center(
                    child: Text(
                      '등록된 벌칙이 없습니다.\n벌칙을 추가해 주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: penalties.length,
                  itemBuilder: (context, index) {
                    final penalty = penalties[index];
                    return PenaltyCard(
                      penalty: penalty,
                      onDelete: () => _deletePenalty(penalty.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}