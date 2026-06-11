import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_pick/database/drift_database.dart';
import 'package:spin_pick/component/penalty_card.dart';

class PenaltyScreen extends StatefulWidget {
  const PenaltyScreen({Key? key}) : super(key: key);

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  final TextEditingController _penaltyController = TextEditingController();

  void _addPenalty() async {
    final content = _penaltyController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('벌칙 내용을 입력해 주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await GetIt.I<LocalDatabase>().createPenalty(
      PenaltiesCompanion.insert(content: content),
    );

    _penaltyController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

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
              await GetIt.I<LocalDatabase>().removePenalty(id);
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
          Expanded(
            child: StreamBuilder<List<Penalty>>(
              stream: GetIt.I<LocalDatabase>().watchPenalties(),
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