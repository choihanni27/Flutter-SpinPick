// 히스토리 관리 화면

// 랜덤 결과 저장 목록 출력
// 날짜 표시
// 전체 삭제

// lib/screen/history_screen.dart

import 'package:flutter/material.dart';
import '../database/drift_database.dart';
import '../component/history_card.dart';

class HistoryScreen extends StatelessWidget {
  final AppDatabase database;

  const HistoryScreen({
    super.key,
    required this.database,
  });

  // 히스토리 전체 삭제 확인 창
  void _clearAllHistories(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('히스토리 초기화'),
        content: const Text('모든 추첨 기록이 영구히 삭제됩니다.\n정말로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await database.clearAllHistories(); // DB 전체 비우기
              if (context.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('기록이 모두 초기화되었습니다.')),
                );
              }
            },
            child: const Text('초기화', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추첨 히스토리'),
        centerTitle: true,
        actions: [
          // 히스토리 전체 초기화 버튼
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: '전체 초기화',
            onPressed: () => _clearAllHistories(context),
          ),
        ],
      ),
      body: StreamBuilder<List<History>>(
        stream: database.watchHistories(), // 최신순 정렬
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final histories = snapshot.data ?? [];

          if (histories.isEmpty) {
            return const Center(
              child: Text(
                '아직 추첨 기록이 없습니다.\n게임을 진행해 보세요! 🎲',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              return HistoryCard(history: history);
            },
          );
        },
      ),
    );
  }
}