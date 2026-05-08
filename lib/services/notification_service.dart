import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Local notifications for subscription renewal alerts.
///
/// Currently exposes immediate `show` + `cancel`. Scheduled (zoned) reminders
/// are intentionally omitted until the timezone package is wired in — adding
/// that later is one init() call and a switch to zonedSchedule.
class NotificationService {
  NotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'tidy_subscription_alerts';
  static const _channelName = 'Subscription alerts';
  static const _channelDescription =
      'Reminders before tracked app subscriptions renew.';

  Future<void> init() async {
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(iOS: ios, android: android),
    );
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
        ),
      ),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}

final notificationPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(notificationPluginProvider)),
);
