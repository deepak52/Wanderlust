import 'package:cloud_firestore/cloud_firestore.dart';

class ResponseModel {
  final String userId;
  final String email;
  final List<String> answers;
  final DateTime timestamp;
  final String? documentId;

  ResponseModel({
    required this.userId,
    required this.email,
    required this.answers,
    required this.timestamp,
    this.documentId,
  });

  factory ResponseModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final List<dynamic> answersDyn = data['answers'] ?? [];
    final List<String> answersList = answersDyn
        .map((e) => e.toString())
        .toList();

    DateTime timestamp;
    try {
      final ts = data['timestamp'];
      if (ts is Timestamp) {
        timestamp = ts.toDate();
      } else if (ts is String) {
        timestamp = DateTime.parse(ts);
      } else {
        timestamp = DateTime.now();
      }
    } catch (_) {
      timestamp = DateTime.now();
    }

    return ResponseModel(
      userId: data['userId'] ?? '',
      email: data['email'] ?? 'No email',
      answers: answersList,
      timestamp: timestamp,
      documentId: documentId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'answers': answers,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  String get answer1 => answers.isNotEmpty ? answers[0] : '';
  String get answer2 => answers.length > 1 ? answers[1] : '';
  String get answer3 => answers.length > 2 ? answers[2] : '';

  String get answerText => 'Q1: $answer1\nQ2: $answer2\nQ3: $answer3';

  /// Getter for document ID (alias for documentId)
  String get id => documentId ?? '';
}
