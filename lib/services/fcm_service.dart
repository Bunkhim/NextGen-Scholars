import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/api/services/notifications_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await registerToken();
    _fcm.onTokenRefresh.listen(_uploadToken);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapData);
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationData(initialMessage.data);
    }

    _initialized = true;
  }

  Future<void> registerToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _uploadToken(token);
  }

  Future<void> _uploadToken(String token) async {
    final uid = JwtService().uidSync;
    if (uid == null) return;
    try {
      await NotificationsApiService().registerDeviceToken(
        token,
        Platform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token upload failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    if (notification != null) {
      _showLocalNotification(
        notification.title ?? '',
        notification.body ?? '',
        data,
      );
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'nextgen_channel',
      'NextGen Notifications',
      channelDescription: 'Notifications from NextGen Scholars',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = data['referenceId']?.hashCode ?? DateTime.now().millisecondsSinceEpoch;
    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromData(data);
      } catch (_) {}
    }
  }

  void _onNotificationTapData(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    _navigateFromData(data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    switch (type) {
      case 'new_scholarship':
      case 'deadline_reminder':
        if (referenceId != null) {
          Get.toNamed(
            AppRoutes.scholarshipDetailScreen,
            arguments: {'scholarshipId': referenceId},
          );
        } else {
          Get.toNamed(AppRoutes.homeScreen);
        }
      case 'application_status':
        Get.toNamed(AppRoutes.homeScreen);
      default:
        Get.toNamed(AppRoutes.homeScreen);
    }
  }
}
