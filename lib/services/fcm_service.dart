import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/api/services/notifications_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings);

  final prefs = await SharedPreferences.getInstance();
  final sound =
      prefs.getString('settings_notification_sound') ?? 'default';

  final data = message.data;
  final title = message.notification?.title ?? data['title'] ?? '';
  final body = message.notification?.body ?? data['body'] ?? '';
  if (title.isEmpty && body.isEmpty && data.isEmpty) return;

  await plugin.show(
    FcmService.notificationIdFor(data),
    title,
    body,
    NotificationDetails(
      android: FcmService.buildAndroidDetails(sound),
      iOS: FcmService.buildDarwinDetails(sound),
    ),
    payload: jsonEncode(data),
  );
}

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
    } else {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
    try {
      final token = await _fcm.getToken();
      if (token != null) await _uploadToken(token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'FCM getToken failed (push may be unavailable on this device): $e',
        );
      }
    }
  }

  /// Unregister this device's FCM token on logout so the previous account
  /// stops receiving push notifications here (prevents cross-account leaks).
  Future<void> unregisterDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await NotificationsApiService().unregisterDeviceToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token unregister failed: $e');
      }
    }
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
    final title = notification?.title ?? data['title'] ?? '';
    final body = notification?.body ?? data['body'] ?? '';
    if (title.isEmpty && body.isEmpty && data.isEmpty) return;
    _showLocalNotification(title, body, data);
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // A distinct channel per sound choice so Android 8+ recreates the channel
    // with the right audio attributes when the setting changes.
    final prefs = await SharedPreferences.getInstance();
    final sound =
        prefs.getString('settings_notification_sound') ?? 'default';

    final details = NotificationDetails(
      android: buildAndroidDetails(sound),
      iOS: buildDarwinDetails(sound),
    );

    await _localNotifications.show(
      notificationIdFor(data),
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Play a test notification immediately with the currently selected sound,
  /// so the sound choice can be previewed on a physical device (the iOS
  /// simulator never plays notification sounds).
  Future<void> showTestNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final sound =
        prefs.getString('settings_notification_sound') ?? 'default';
    final details = NotificationDetails(
      android: buildAndroidDetails(sound),
      iOS: buildDarwinDetails(sound),
    );
    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  static AndroidNotificationDetails buildAndroidDetails(String sound) {
    switch (sound) {
      case 'silent':
        return const AndroidNotificationDetails(
          'nextgen_silent',
          'NextGen Notifications',
          channelDescription: 'Notifications from NextGen Scholars',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
        );
      case 'vibrate':
        return const AndroidNotificationDetails(
          'nextgen_vibrate',
          'NextGen Notifications',
          channelDescription: 'Notifications from NextGen Scholars',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
        );
      case 'chime':
        return const AndroidNotificationDetails(
          'nextgen_chime',
          'NextGen Notifications',
          channelDescription: 'Notifications from NextGen Scholars',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('nextgen_chime'),
        );
      default:
        return const AndroidNotificationDetails(
          'nextgen_channel',
          'NextGen Notifications',
          channelDescription: 'Notifications from NextGen Scholars',
          importance: Importance.high,
          priority: Priority.high,
        );
    }
  }

  static int notificationIdFor(Map<String, dynamic> data) {
    final rawId = data['referenceId']?.hashCode ??
        DateTime.now().millisecondsSinceEpoch;
    return rawId & 0x7fffffff;
  }

  /// Maps the sound preference to iOS notification presentation.
  ///
  /// iOS has no vibration-only API (sound is always played when it vibrates),
  /// so 'vibrate' falls back to the default sound. 'chime' plays the bundled
  /// `nextgen_chime.wav`; 'silent' suppresses sound entirely. Must be a
  /// non-const build because `sound` and `presentSound` come from the setting.
  static DarwinNotificationDetails buildDarwinDetails(String sound) {
    switch (sound) {
      case 'silent':
        return const DarwinNotificationDetails(presentSound: false);
      case 'chime':
        return const DarwinNotificationDetails(sound: 'nextgen_chime.wav');
      default:
        return const DarwinNotificationDetails();
    }
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
