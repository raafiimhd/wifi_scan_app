import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'controller/wifi_task_handler.dart';
import 'screens/wifi_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Foreground Task
  FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'wifi_service',
    channelName: 'WiFi Monitoring Service',
    channelDescription: 'Keeps scanning WiFi in background',
    channelImportance: NotificationChannelImportance.LOW,
    priority: NotificationPriority.LOW,
  ),
  iosNotificationOptions: const IOSNotificationOptions(
    showNotification: true,
    playSound: false,
  ),
  foregroundTaskOptions: ForegroundTaskOptions(
    autoRunOnBoot: true,
    allowWakeLock: true,
    allowWifiLock: true,
    eventAction: ForegroundTaskEventAction.repeat(5000), // Add the required eventAction parameter
  ),
);

  runApp(const MyApp());
}

/// Foreground service entry point
void wifiScanTask() {
  FlutterForegroundTask.setTaskHandler(WifiTaskHandler());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WifiScannerApp(),
    );
  }
}
