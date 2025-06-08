import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../shared/active_chat_tracker.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  try {
    final data = message.data;
    final String? chatId = data['chatId'];
    final String? messageId = data['messageId'];
    final String? wakeType = data['wakeType'];

    print("🌙 Background notification received with wakeType: $wakeType");

    if (wakeType == null || wakeType == 'message') {
      if (chatId != null && messageId != null) {
        await NotificationHelper._markMessageAsDelivered(chatId, messageId);
        print("📦 Background: Message marked as delivered in Firestore");
      } else {
        print(
          "⚠️ Background: chatId or messageId missing in notification data",
        );
      }
    }

    if (wakeType == 'wakeOnly') {
      print("🌐 Background: Wake-only task triggered.");
    }
  } catch (e) {
    print("❌ Background error: $e");
  }
}

class NotificationHelper {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> clearAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('🔔 All notifications cleared');
  }

  static Future<void> initializeFCM() async {
    bool granted = await checkPermissionStatus();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initializeLocalNotifications();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});
        print('🔁 Token refreshed and updated in Firestore');
      }
    });

    if (!granted) {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('❌ User declined or has not accepted permission');
        return;
      }
      print('✅ User granted permission');
    } else {
      print('✅ Permission already granted');
    }

    String? token = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $token');
  }

  static Future<bool> checkPermissionStatus() async {
    NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  static void setUpForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final data = message.data;
      final String? title = notification?.title;
      final String? body = notification?.body;
      final String? imageUrl =
          notification?.android?.imageUrl ?? notification?.apple?.imageUrl;
      final String? chatId = data['chatId'];
      final String? messageId = data['messageId'];

      print('🔔 Foreground Notification: $title');
      print('📩 Body: $body');
      print('🖼️ Image: $imageUrl');

      try {
        if (chatId != null && messageId != null) {
          await _markMessageAsDelivered(chatId, messageId);
          print("✅ Foreground: Message marked as delivered in Firestore");
        } else {
          print(
            "⚠️ Foreground: chatId or messageId missing in notification data",
          );
        }
      } catch (e) {
        print("❌ Foreground error marking message as delivered: $e");
      }

      if (chatId != null && ActiveChatTracker.instance.isActive(chatId)) {
        print("🔕 Suppressing local notification for active chatId: $chatId");
        return;
      }

      _showLocalNotification(title, body, imageUrl: imageUrl);
    });
  }

  static Future<void> saveTokenToFirestore(bool isAdmin) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No logged-in user found.');
      return;
    }

    String? token = await _firebaseMessaging.getToken();
    if (token == null) {
      print('❌ Could not get FCM token');
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'isAdmin': isAdmin,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ FCM token saved for ${isAdmin ? "admin" : "user"}');
    } catch (e) {
      print('❌ Failed to save token: $e');
    }
  }

  static void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static Future<void> _showLocalNotification(
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
        print('❌ Failed to load image for notification: $e');
        androidDetails = _defaultAndroidDetails();
      }
    } else {
      androidDetails = _defaultAndroidDetails();
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  static AndroidNotificationDetails _defaultAndroidDetails() {
    return AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// 🔁 Shared delivery confirmation logic
  static Future<void> _markMessageAsDelivered(
    String chatId,
    String messageId,
  ) async {
    try {
      final DocumentReference msgRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      await msgRef.update({'delivered': true});
    } catch (e) {
      print(
        "❌ Error updating 'delivered' for chatId=$chatId, messageId=$messageId: $e",
      );
    }
  }
}
