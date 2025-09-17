import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WifiTaskHandler extends TaskHandler {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Map<String, bool> _wifiStates = {}; // track Wi-Fi in/out state
  static const int rssiThreshold = -70;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    await _scanWifi();
  }

  Future<void> _scanWifi() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }

    final results = await WiFiScan.instance.getScannedResults();

    for (var ap in results) {
      final ssid = ap.ssid;
      final isInRange = ap.level > rssiThreshold;
      final wasInRange = _wifiStates[ssid] ?? false;

      if (isInRange && !wasInRange) {
        _showNotification("Nearby Wi-Fi", "$ssid entered range (${ap.level} dBm)");
      } else if (!isInRange && wasInRange) {
        _showNotification("Wi-Fi Lost", "$ssid went out of range (weak signal)");
      }

      _wifiStates[ssid] = isInRange;
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const android = AndroidNotificationDetails(
      'wifi_channel',
      'Wi-Fi Alerts',
      channelDescription: 'Alerts when Wi-Fi is nearby or lost',
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
  void onButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    } else if (id == 'scan') {
      _scanWifi();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isAppRestart) async {
    // cleanup if needed
  }
}
