import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../service/active_chat_tracker.dart';
import '../service/chat_sound_player.dart';
import '../helper/app_message.dart';

/// Background message handler for FCM
/// Must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs in a separate isolate, so we need to initialize Firebase again
  // The main app initialization will handle this

  try {
    final data = message.data;
    final String? chatId = data['chatId'];
    final String? messageId = data['messageId'];
    final String? wakeType = data['wakeType'];

    misInfoMessage(
      '🌙 Background notification received with wakeType: $wakeType',
    );

    if (wakeType == null || wakeType == 'message') {
      if (chatId != null && messageId != null) {
        await _markMessageAsDelivered(chatId, messageId);
        misInfoMessage(
          '📦 Background: Message marked as delivered in Firestore',
        );
      } else {
        misWarningMessage(
          '⚠️ Background: chatId or messageId missing in notification data',
        );
      }
    }

    if (wakeType == 'wakeOnly') {
      misInfoMessage('🌐 Background: Wake-only task triggered.');
    }
  } catch (e) {
    misErrorMessage('❌ Background error: $e');
  }
}

/// Shared function to mark message as delivered in Firestore
/// Used by both foreground and background handlers
Future<void> _markMessageAsDelivered(String chatId, String messageId) async {
  try {
    final DocumentReference msgRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await msgRef.update({'delivered': true});
  } catch (e) {
    misErrorMessage(
      "❌ Error updating 'delivered' for chatId=$chatId, messageId=$messageId: $e",
    );
  }
}

class FirebaseMessagingService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Lazy-initialized services
  ActiveChatTracker? _activeChatTracker;
  ChatSoundPlayer? _chatSoundPlayer;

  ActiveChatTracker get _activeChatTrackerInstance =>
      _activeChatTracker ??= Get.find<ActiveChatTracker>();

  ChatSoundPlayer get _chatSoundPlayerInstance =>
      _chatSoundPlayer ??= Get.find<ChatSoundPlayer>();

  Future<void> initialize() async {
    // Initialize FlutterLocalNotificationsPlugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@drawable/ic_launcher',
        ); // Replace with your icon name
    // const IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings();
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          // No `onDidReceiveLocalNotification` in the latest version
          notificationCategories: [
            DarwinNotificationCategory(
              'category_id',
              actions: [
                DarwinNotificationAction.plain('action_id', 'Action Title'),
              ],
            ),
          ],
        );
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
      onDidReceiveBackgroundNotificationResponse:
          (NotificationResponse response) async {},
    );

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      sound: true,
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received message in foreground: $message');
      await _handleForegroundMessage(message);
    });

    // Handle initial message when the app is cold launched
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      misInfoMessage('Received message on app launch: $initialMessage');
      _handleMessage(
        initialMessage,
      ); // Define your handling logic for the initial message
    }

    // Handle background messages (Android only, not web)
    if (!kIsWeb && Platform.isAndroid) {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        misInfoMessage('Received message when app was background: $message');
        _handleMessage(
          message,
        ); // Define your handling logic for background messages (Android)
      });
    }

    // Subscribe to topic(s) if needed (optional)
    // await FirebaseMessaging.instance.subscribeToTopic('your_topic');

    // Handle token refresh (optional)
    FirebaseMessaging.instance
        .getToken()
        .then((token) async {
          misInfoMessage('Push Notification Token: $token');
        })
        .catchError((error) {
          misErrorMessage('Error getting push notification token: $error');
        });
  }

  /// Handle foreground messages with chat-specific logic
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final String? title = notification?.title;
    final String? body = notification?.body;
    final String? imageUrl =
        notification?.android?.imageUrl ?? notification?.apple?.imageUrl;
    final String? chatId = data['chatId'];
    final String? messageId = data['messageId'];

    misInfoMessage('🔔 Foreground Notification: $title');
    misInfoMessage('📩 Body: $body');
    misInfoMessage('🖼️ Image: $imageUrl');

    try {
      // Mark message as delivered in Firestore if chat data present
      if (chatId != null && messageId != null) {
        await _markMessageAsDelivered(chatId, messageId);
        misInfoMessage(
          '✅ Foreground: Message marked as delivered in Firestore',
        );
      } else {
        misWarningMessage(
          '⚠️ Foreground: chatId or messageId missing in notification data',
        );
      }
    } catch (e) {
      misErrorMessage('❌ Foreground error marking message as delivered: $e');
    }

    // Suppress local notification if chat is currently active
    if (chatId != null && _activeChatTrackerInstance.isActive(chatId)) {
      misInfoMessage(
        '🔕 Suppressing local notification for active chatId: $chatId',
      );
      return;
    }

    // Play receive sound for chat messages
    if (chatId != null) {
      await _chatSoundPlayerInstance.playReceiveSound();
    }

    // Show local notification
    await _showLocalNotification(title, body, imageUrl: imageUrl);
  }

  void _handleMessage(RemoteMessage message) {
    // Handle notification data payload, navigate to screens, etc.
    // Example:
    final String title = message.notification!.title!;
    final String body = message.notification!.body!;
    misInfoMessage('Notification title: $title, body: $body');
  }

  /// Show local notification with optional big picture
  Future<void> _showLocalNotification(
    String? title,
    String? body, {
    String? imageUrl,
  }) async {
    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String largeIconPath = await _downloadAndSaveFile(
          imageUrl,
          'largeIcon',
        );
        final String bigPicturePath = await _downloadAndSaveFile(
          imageUrl,
          'bigPicture',
        );

        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              largeIcon: FilePathAndroidBitmap(largeIconPath),
              contentTitle: title,
              summaryText: body,
            );

        androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigPictureStyleInformation,
          playSound: true,
        );
      } catch (e) {
        misErrorMessage('❌ Failed to load image for notification: $e');
        androidDetails = _defaultAndroidDetails();
      }
    } else {
      androidDetails = _defaultAndroidDetails();
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  AndroidNotificationDetails _defaultAndroidDetails() {
    return AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      misErrorMessage('Error getting FCM token: $e');
      return null;
    }
  }
}
