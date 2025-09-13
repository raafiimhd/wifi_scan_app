import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WifiController extends GetxController {
  var networks = <WiFiAccessPoint>[].obs;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int RSSI_THRESHOLD = -70;

  WifiController() {
    _initNotifications();
    scanAndCheck();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  Future<void> scanAndCheck() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }

    final results = await WiFiScan.instance.getScannedResults();
    networks.value = results;

    for (var ap in results) {
      if (ap.level > RSSI_THRESHOLD) {
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
    await _notifications.show(0, title, body, details);
  }
}
