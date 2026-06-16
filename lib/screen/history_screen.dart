// 히스토리 관리 화면
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_pick/database/drift_database.dart';
import 'package:spin_pick/component/history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

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
              await GetIt.I<LocalDatabase>().clearHistories();
              if (context.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('기록이 모두 초기화되었습니다.')),
                );
              }
            },
            child: const Text('초기화', style: TextStyle(color: Color(0xFFCC2827),)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추첨 기록'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: '전체 초기화',
            onPressed: () => _clearAllHistories(context),
          ),
        ],
      ),
      body: StreamBuilder<List<History>>(
        stream: GetIt.I<LocalDatabase>().watchHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final histories = snapshot.data ?? [];

          if (histories.isEmpty) {
            return const Center(
              child: Text(
                '벌칙 추첨 기록이 없습니다.',
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