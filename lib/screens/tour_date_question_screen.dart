import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import '../services/missed_message_service.dart';
import '../helpers/notification_helper.dart';

class TourDateQuestionScreen extends StatefulWidget {
  const TourDateQuestionScreen({super.key});

  @override
  State<TourDateQuestionScreen> createState() => _TourDateQuestionScreenState();
}

class _TourDateQuestionScreenState extends State<TourDateQuestionScreen> {
  final PageController _controller = PageController();
  final List<String> _questions = [
    'Where would you like to go on a tour?',
    'What kind of experience are you looking for?',
    'Do you prefer solo travel or group travel?',
  ];
  final List<String> _answers = ['', '', ''];
  int _currentPage = 0;

  Future<void> _saveAnswersAndNavigateToChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      // Save responses to Firestore
      await FirebaseFirestore.instance.collection('responses').doc(userId).set({
        'answers': _answers,
        'userId': userId,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch admin user dynamically
      final adminQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .where('isAdmin', isEqualTo: true)
              .limit(1)
              .get();

      if (adminQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin user not found')));
        return;
      }

      final adminId = adminQuery.docs.first.id;
      final chatId = '${adminId}_$userId';

      if (!mounted) return;

      // Navigate to ChatScreen with dynamic chatId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chatId, isAdmin: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _nextPage() {
    if (_answers[_currentPage].isEmpty) return;
    if (_currentPage < _questions.length - 1) {
      setState(() => _currentPage++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _saveAnswersAndNavigateToChat();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    MissedMessageService().dispose();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ), // Navigate to Login Screen
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    NotificationHelper.clearAllNotifications();
    return PopScope(
      canPop: false, // Prevent navigating back
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tour Questionnaire'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _questions[index],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (val) => _answers[index] = val,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (index > 0)
                        ElevatedButton(
                          onPressed: _previousPage,
                          child: const Text('Go Back'),
                        ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        child: Text(
                          index == _questions.length - 1
                              ? 'Finish'
                              : 'Continue',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
