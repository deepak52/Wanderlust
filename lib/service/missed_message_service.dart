// missed_message_service.dart
// Missed Message Service - Fetches undelivered messages when connectivity restored
// Following Agro-Prod patterns: extends AppBaseService, uses GetX DI, connectivity monitoring

import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/app_message.dart';
import '../helper/core/base/app_base_service.dart';

/// Missed Message Service - Fetches undelivered messages when connectivity restored
/// Handles background sync of message delivery status
class MissedMessageService extends AppBaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicTimer;

  @override
  void initialize() {
    developer.log('MissedMessageService initialize called');
  }

  @override
  void dispose() {
    developer.log('MissedMessageService dispose called');
  }

  /// Call this once on app startup or user login
  void startListening() {
    misInfoMessage('[MissedMessageService] Starting connectivity listener');

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Check if any connection is available (not none)
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      if (hasConnection) {
        misInfoMessage(
          '[MissedMessageService] Connectivity restored, fetching missed messages...',
        );
        fetchMissedMessages();
      }
    });

    // Also fetch missed messages immediately
    fetchMissedMessages();

    // Start periodic timer (every 5 minutes)
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      misInfoMessage(
        '[MissedMessageService] Periodic check, fetching missed messages...',
      );
      fetchMissedMessages();
    });
  }

  /// Call this when app is disposed or user logs out
  void disposeResources() {
    misInfoMessage('[MissedMessageService] Disposing resources');
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
  }

  /// Generate consistent chat ID from two user IDs
  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Fetch missed messages and update delivery statuses
  Future<void> fetchMissedMessages() async {
    final user = _auth.currentUser;
    if (user == null) {
      misWarningMessage(
        '[MissedMessageService] No logged in user, skipping fetch.',
      );
      return;
    }

    final currentUserId = user.uid;

    try {
      misInfoMessage(
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
          misInfoMessage(
            '[MissedMessageService] Marked message ${msgDoc.id} in chat $chatId as delivered',
          );
        }
      }
    } catch (e) {
      misErrorMessage(
        '[MissedMessageService] Error fetching missed messages: $e',
      );
    }
  }
}
