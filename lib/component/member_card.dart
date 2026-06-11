// lib/component/member_card.dart

import 'package:flutter/material.dart';
import '../database/drift_database.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onDelete;

  const MemberCard({
    super.key,
    required this.member,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.blue),
        title: Text(
          member.name,
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