import 'dart:async';
import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WifiController extends GetxController {
  var networks = <WiFiAccessPoint>[].obs;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int RSSI_THRESHOLD = -70;

  // Track last known state of each SSID
  final Map<String, bool> _wifiStates = {};
  Timer? _scanTimer;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    _startContinuousScan();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  void _startContinuousScan() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      scanAndCheck();
    });
  }

  Future<void> scanAndCheck() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }

    final results = await WiFiScan.instance.getScannedResults();
    networks.value = results;

    for (var ap in results) {
      final ssid = ap.ssid;
      final isInRange = ap.level > RSSI_THRESHOLD;
      final wasInRange = _wifiStates[ssid] ?? false;

      // Notify only when state changes
      if (isInRange && !wasInRange) {
        _showNotification("$ssid is nearby", "Signal: ${ap.level} dBm");
      } else if (!isInRange && wasInRange) {
        _showNotification("$ssid is out of range", "Signal weak");
      }

      _wifiStates[ssid] = isInRange;
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      details,
    );
  }

  @override
  void onClose() {
    _scanTimer?.cancel();
    super.onClose();
  }
}
