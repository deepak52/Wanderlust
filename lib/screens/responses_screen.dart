import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ResponsesScreen extends StatelessWidget {
  const ResponsesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference responsesCol = FirebaseFirestore.instance
        .collection('responses');

    return Scaffold(
      appBar: AppBar(title: const Text('User Responses')),
      body: StreamBuilder<QuerySnapshot>(
        stream: responsesCol.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No responses found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String email = data['email'] ?? 'No email';
              final List<dynamic> answersDyn = data['answers'] ?? [];
              final List<String> answersList = List<String>.from(answersDyn);

              final String answer1 =
                  answersList.isNotEmpty ? answersList[0] : '';
              final String answer2 =
                  answersList.length > 1 ? answersList[1] : '';
              final String answer3 =
                  answersList.length > 2 ? answersList[2] : '';

              final String answerText =
                  'Q1: $answer1\nQ2: $answer2\nQ3: $answer3';
              final String userId = data['userId'] ?? '';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                title: Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(answerText),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Delete Response'),
                            content: Text(
                              'Are you sure you want to delete $email\'s responses?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('responses')
                            .doc(userId)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Response deleted')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting response: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ChatScreen(chatId: userId, isAdmin: true),
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
