import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Static method to access singleton
  static NotificationService get instance => _instance;

  // Static initialize method
  static Future<void> initialize() async {
    await _instance._initialize();
  }

  // Static display method
  static Future<void> display(RemoteMessage message) async {
    await _instance._handleForegroundMessage(message);
  }

  // Private instance initialize
  Future<void> _initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notification permission granted');
    }

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('notification_icon'); 
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tripmate_channel',
      'TripMate Notifications',
      description: 'Notifications for ride updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get FCM Token
    String? token = await _fcm.getToken();
    debugPrint('📱 FCM Token: $token');
  }

  // Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 Foreground Message: ${message.notification?.title}');

    // Show local notification when app is in foreground
    await _showLocalNotification(
      title: message.notification?.title ?? 'TripMate',
      body: message.notification?.body ?? '',
      payload: message.data['rideId'] ?? '',
    );
  }

  // Show local notification
Future<void> _showLocalNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'tripmate_channel',
    'TripMate Notifications',
    channelDescription: 'Notifications for ride updates',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    
    // 1. The small white bike silhouette for status bar
    icon: 'notification_icon', 
    
    // 2. USE THE NEW FILENAME HERE to avoid the XML crash
    largeIcon: DrawableResourceAndroidBitmap('app_icon_colorful'), 
    
    color: Color(0xFFF9F5E9), 
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
    payload: payload,
  );
}

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
  }

  // Get FCM Token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // Listen to token refresh
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _fcm.onTokenRefresh.listen(onTokenRefresh);
  }
}