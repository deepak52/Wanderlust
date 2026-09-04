import 'package:cloud_firestore/cloud_firestore.dart';
import 'adventure_state_model.dart';

class ResponseModel {
  final String userId;
  final String email;
  final List<String> answers;
  final DateTime timestamp;
  final String? documentId;
  final bool adventureCompleted;
  final String? invitationResponse;
  final Map<String, String> adventureChoices;
  final List<MapLandmarkNode> mapNodes;
  final List<MapRouteSegment> mapSegments;

  ResponseModel({
    required this.userId,
    required this.email,
    required this.answers,
    required this.timestamp,
    this.documentId,
    this.adventureCompleted = false,
    this.invitationResponse,
    this.adventureChoices = const {},
    this.mapNodes = const [],
    this.mapSegments = const [],
  });

  factory ResponseModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final List<dynamic> answersDyn = data['answers'] ?? [];
    final List<String> answersList =
        answersDyn.map((e) => e.toString()).toList();

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

    final bool completed = data['adventureCompleted'] as bool? ?? false;
    final String? invitation = data['invitationResponse'] as String?;

    // Parse choices map
    final Map<String, String> choices = {};
    if (data['adventureChoices'] is Map) {
      (data['adventureChoices'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          choices[k.toString()] = v.toString();
        }
      });
    }

    // Parse map nodes & segments
    final List<MapLandmarkNode> nodes = [];
    final List<MapRouteSegment> segments = [];

    if (data['adventureMap'] is Map) {
      final mapData = data['adventureMap'] as Map<String, dynamic>;
      if (mapData['nodes'] is List) {
        for (final item in mapData['nodes'] as List) {
          if (item is Map<String, dynamic>) {
            try {
              nodes.add(MapLandmarkNode.fromJson(item));
            } catch (_) {}
          }
        }
      }
      if (mapData['segments'] is List) {
        for (final item in mapData['segments'] as List) {
          if (item is Map<String, dynamic>) {
            try {
              segments.add(MapRouteSegment.fromJson(item));
            } catch (_) {}
          }
        }
      }
    }

    return ResponseModel(
      userId: data['userId'] ?? documentId,
      email: data['email'] ?? 'No email',
      answers: answersList,
      timestamp: timestamp,
      documentId: documentId,
      adventureCompleted: completed,
      invitationResponse: invitation,
      adventureChoices: choices,
      mapNodes: nodes,
      mapSegments: segments,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'answers': answers,
      'timestamp': Timestamp.fromDate(timestamp),
      'adventureCompleted': adventureCompleted,
      'invitationResponse': invitationResponse,
      'adventureChoices': adventureChoices,
      'adventureMap': {
        'nodes': mapNodes.map((n) => n.toJson()).toList(),
        'segments': mapSegments.map((s) => s.toJson()).toList(),
        'version': 1,
      },
    };
  }

  String get answer1 => answers.isNotEmpty ? answers[0] : '';
  String get answer2 => answers.length > 1 ? answers[1] : '';
  String get answer3 => answers.length > 2 ? answers[2] : '';

  String get answerText => answers.join('\n');

  /// Getter for document ID (alias for documentId)
  String get id => documentId ?? '';
}
