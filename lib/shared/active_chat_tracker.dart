class ActiveChatTracker {
  static final ActiveChatTracker _instance = ActiveChatTracker._internal();

  String? _activeChatId;

  ActiveChatTracker._internal();

  static ActiveChatTracker get instance => _instance;

  void setActiveChat(String chatId) {
    _activeChatId = chatId;
  }

  void clearActiveChat() {
    _activeChatId = null;
  }

  String? get activeChatId => _activeChatId;

  bool isActive(String chatId) => _activeChatId == chatId;
}
