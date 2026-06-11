// lib/component/penalty_card.dart

import 'package:flutter/material.dart';
import '../database/drift_database.dart';

class PenaltyCard extends StatelessWidget {
  final Penalty penalty;
  final VoidCallback onDelete;

  const PenaltyCard({
    super.key,
    required this.penalty,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.amber.shade50,
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        title: Text(
          penalty.content,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}