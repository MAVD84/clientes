import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/client_model.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    developer.log('NotificationHelper initialized.', name: 'my_app.notification_helper');
  }

  static Future<void> scheduleExpirationNotifications(Client client) async {
    developer.log('Scheduling notifications for client: ${client.name}', name: 'my_app.notification_helper');
    final now = tz.TZDateTime.now(tz.local);
    final endDate = tz.TZDateTime.from(client.endDate, tz.local);

    await cancelNotificationsForClient(client.id!);

    for (int days in [3, 2, 1, 0]) {
      final scheduledDate = endDate.subtract(Duration(days: days));

      if (scheduledDate.isAfter(now)) {
        final id = client.id! * 10 + days; 
        String title = 'Recordatorio de Expiración';
        String body;

        if (days > 0) {
          body = 'La suscripción de ${client.name} expira en $days día(s).';
        } else {
          body = 'La suscripción de ${client.name} ha expirado hoy.';
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'expiring_clients_channel',
              'Expiring Clients',
              channelDescription: 'Notifications for clients that are about to expire',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        developer.log('Scheduled notification for ${client.name} at $scheduledDate', name: 'my_app.notification_helper');
      } else {
        developer.log('Skipped scheduling for ${client.name} at $scheduledDate because it is in the past.', name: 'my_app.notification_helper');
      }
    }
  }

  static Future<void> cancelNotificationsForClient(int clientId) async {
    developer.log('Cancelling notifications for client ID: $clientId', name: 'my_app.notification_helper');
    for (int days in [3, 2, 1, 0]) {
      final id = clientId * 10 + days;
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
  }
}
