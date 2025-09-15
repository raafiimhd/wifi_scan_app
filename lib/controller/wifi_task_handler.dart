import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background callback
void wifiScanTask() {
  FlutterForegroundTask.setTaskHandler(WifiTaskHandler());
}

class WifiTaskHandler extends TaskHandler {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  /// Called when the task is triggered (manual or scheduled)
  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    await _scanWifi();
  }

  /// Called repeatedly based on [ForegroundTaskOptions.interval]
  @override
  void onRepeatEvent(DateTime timestamp) {
    _scanWifi();
  }

  Future<void> _scanWifi() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }
    final results = await WiFiScan.instance.getScannedResults();

    for (var ap in results) {
      if (ap.level > -70) {
        _showNotification("${ap.ssid} is nearby", "Signal: ${ap.level} dBm");
      } else {
        _showNotification("${ap.ssid} is out of range", "Signal weak");
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const android = AndroidNotificationDetails(
      'wifi_channel',
      'Wi-Fi Alerts',
      channelDescription: 'Wi-Fi in/out range alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isAppRestart) async {
    // cleanup logic if needed
  }

  @override
  void onButtonPressed(String id) {
    // handle notification button presses if you add them
  }
}
