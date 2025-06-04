import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart'; // ✅ Use shared ChatScreen

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  // ✅ Helper to generate consistent chatId using both UIDs
  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User to Chat')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .where('isAdmin', isEqualTo: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final email = user['email'] ?? 'No Email';

              return ListTile(
                title: Text(email),
                trailing: const Icon(Icons.chat),
                onTap: () async {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser == null) return;

                  final adminId = currentUser.uid;
                  final chatId = generateChatId(
                    adminId,
                    userId,
                  ); // ✅ Proper chatId

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId, isAdmin: true),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
