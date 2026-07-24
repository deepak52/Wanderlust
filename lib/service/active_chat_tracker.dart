// active_chat_tracker.dart
// Active Chat Tracker - Migrated from Wanderlust
// Follows Agro-Prod patterns: GetX service for global state tracking

import 'package:get/get.dart';

import '../helper/app_message.dart';

/// Service to track which chat is currently active/open
/// Used to suppress notifications when user is already in that chat
class ActiveChatTracker extends GetxService {
  static ActiveChatTracker get instance => Get.find<ActiveChatTracker>();

  /// Currently active chat ID (null if no chat open)
  final RxString _activeChatId = ''.obs;

  String? get activeChatId =>
      _activeChatId.value.isEmpty ? null : _activeChatId.value;

  /// Whether a specific chat is currently active
  bool isActive(String chatId) => _activeChatId.value == chatId;

  /// Set the active chat (called when user opens a chat)
  void setActiveChat(String chatId) {
    _activeChatId.value = chatId;
    misInfoMessage('🟢 ActiveChatTracker: Active chat set to $chatId');
  }

  /// Clear the active chat (called when user leaves chat)
  void clearActiveChat() {
    misInfoMessage(
      '🔴 ActiveChatTracker: Active chat cleared (was: ${_activeChatId.value})',
    );
    _activeChatId.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    misInfoMessage('📦 ActiveChatTracker initialized');
  }
}
