import 'package:flutter/material.dart';
import 'package:spin_pick/database/drift_database.dart';

class HistoryCard extends StatelessWidget {
  final History history;

  const HistoryCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = "${history.date.year}-${history.date.month.toString().padLeft(2, '0')}-${history.date.day.toString().padLeft(2, '0')} ${history.date.hour.toString().padLeft(2, '0')}:${history.date.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      history.memberName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Text(' 님 당첨! 🎯', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              "벌칙: ${history.penalty}",
              style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}