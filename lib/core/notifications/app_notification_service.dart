import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigation/app_router.dart';

class AppNotificationService {
  AppNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _sceneChannelId = 'scene_generation';
  static const String _sceneChannelName = 'Scene generation';
  static const String _sceneChannelDescription =
      'Notifications when generated scenes are ready.';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentBanner: false,
      defaultPresentList: false,
      defaultPresentSound: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _sceneChannelId,
            _sceneChannelName,
            description: _sceneChannelDescription,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    await initialize();

    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (androidGranted != null) {
      return androidGranted;
    }

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (iosGranted != null) {
      return iosGranted;
    }

    final macGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (macGranted != null) {
      return macGranted;
    }

    return true;
  }

  static Future<void> showSceneReady({
    required String sceneId,
    required String title,
    required String body,
  }) async {
    await initialize();

    final notificationTitle = title.trim().isEmpty ? 'Scene is ready' : title;
    final notificationBody = body.trim().isEmpty
        ? 'Your generated scene is available in Chat and History.'
        : body;

    await _plugin.show(
      id: sceneId.hashCode,
      title: notificationTitle,
      body: notificationBody,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _sceneChannelId,
          _sceneChannelName,
          channelDescription: _sceneChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      ),
      payload: 'scene:$sceneId',
    );
  }

  static void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    if (payload.startsWith('scene:')) {
      appRouter.go('/chat');
      return;
    }

    if (kDebugMode) {
      debugPrint('[Notifications] Unhandled notification payload: $payload');
    }
  }
}
