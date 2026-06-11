// 참가자 관리 화면

// 참가자 추가
// 참가자 삭제
// 참가자 목록 출력

import 'package:flutter/material.dart';
import '../database/drift_database.dart';
import '../component/member_card.dart';

class MemberScreen extends StatefulWidget {
  final AppDatabase database;

  const MemberScreen({
    super.key,
    required this.database,
  });

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final TextEditingController _nameController = TextEditingController();

  // 멤버 추가
  void _addMember() async {
    final name = _nameController.text.trim();

    // 빈값 입력 방지
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버 이름을 입력해 주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // DB에 멤버 추가
    await widget.database.insertMember(
      MembersCompanion.insert(name: name),
    );

    // 입력창 초기화 및 키보드 닫기
    _nameController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  // 멤버 삭제
  void _deleteMember(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 삭제'),
        content: const Text('정말로 이 멤버를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 취소
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await widget.database.deleteMember(id); // DB에서 삭제
              if (mounted) Navigator.pop(context); // 팝업 닫기
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
          // 1. 입력 영역 (상단)
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
                    onSubmitted: (_) => _addMember(), // 엔터 누르면 추가
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

          // 멤버 리스트 영역
          Expanded(
            child: StreamBuilder<List<Member>>(
              stream: widget.database.watchMembers(), // DB 실시간 감시
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