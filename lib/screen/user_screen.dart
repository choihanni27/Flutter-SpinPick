// 멤버 관리 화면

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_pick/database/drift_database.dart';
import 'package:spin_pick/component/member_card.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _addMember() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버 이름을 입력해 주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await GetIt.I<LocalDatabase>().createMember(
      MembersCompanion.insert(name: name),
    );

    _nameController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  void _deleteMember(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 삭제'),
        content: const Text('정말로 이 멤버를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await GetIt.I<LocalDatabase>().removeMember(id);
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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멤버 관리'),
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: '새로운 멤버 이름 입력',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _addMember(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addMember,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Member>>(
              stream: GetIt.I<LocalDatabase>().watchMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = snapshot.data ?? [];

                if (members.isEmpty) {
                  return const Center(
                    child: Text(
                      '등록된 멤버가 없습니다.\n멤버를 추가해 주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return MemberCard(
                      member: member,
                      onDelete: () => _deleteMember(member.id),
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