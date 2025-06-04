import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MissedMessageService {
  // Singleton pattern
  static final MissedMessageService _instance =
      MissedMessageService._internal();
  factory MissedMessageService() => _instance;
  MissedMessageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicTimer;

  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Call this once on app startup or user login
  void startListening() {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (result != ConnectivityResult.none) {
        print(
          '[MissedMessageService] Connectivity restored, fetching missed messages...',
        );
        fetchMissedMessages();
      }
    });

    // Also fetch missed messages immediately
    fetchMissedMessages();

    // Start periodic timer (e.g. every 5 minutes)
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      print(
        '[MissedMessageService] Periodic check, fetching missed messages...',
      );
      fetchMissedMessages();
    });
  }

  /// Call this when app is disposed or user logs out
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
  }

  /// Fetch missed messages and update delivery statuses
  Future<void> fetchMissedMessages() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('[MissedMessageService] No logged in user, skipping fetch.');
      return;
    }
    final currentUserId = user.uid;

    try {
      print(
        '[MissedMessageService] Fetching missed messages for user $currentUserId',
      );

      // Get all users except current user
      final usersSnapshot =
          await _firestore
              .collection('users')
              .where(FieldPath.documentId, isNotEqualTo: currentUserId)
              .get();

      for (final userDoc in usersSnapshot.docs) {
        final otherUserId = userDoc.id;
        final chatId = generateChatId(currentUserId, otherUserId);

        final messagesSnapshot =
            await _firestore
                .collection('chats')
                .doc(chatId)
                .collection('messages')
                .where('receiverId', isEqualTo: currentUserId)
                .where('delivered', isEqualTo: false)
                .get();

        for (final msgDoc in messagesSnapshot.docs) {
          await msgDoc.reference.update({
            'delivered': true,
            'deliveredAt': FieldValue.serverTimestamp(),
          });
          print(
            '[MissedMessageService] Marked message ${msgDoc.id} in chat $chatId as delivered',
          );
        }
      }
    } catch (e) {
      print('[MissedMessageService] Error fetching missed messages: $e');
    }
  }
}
