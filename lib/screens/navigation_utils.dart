import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';



Future<void> navigateToChatScreen(BuildContext context, bool isAdmin) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;

  final adminQuery =
      await FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

  if (adminQuery.docs.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin not available')));
    return;
  }

  final adminId = adminQuery.docs.first.id;
  final chatId = '${adminId}_$userId';
 

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(chatId: chatId, isAdmin: isAdmin),
    ),
  );

 

 
}
