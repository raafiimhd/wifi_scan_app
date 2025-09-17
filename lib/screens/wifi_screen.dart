import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:wifi_scanner_app/main.dart';
import '../controller/wifi_controller.dart';

class WifiScannerApp extends StatelessWidget {
  const WifiScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wifiController = Get.put(WifiController());

    return Scaffold(
      appBar: AppBar(title: const Text("WiFi Monitor")),
      body: Column(
        children: [
          Obx(
            () => Expanded(
              child: ListView(
                children:
                    wifiController.networks
                        .map(
                          (n) => ListTile(
                            title: Text(n.ssid),
                            subtitle: Text("RSSI: ${n.level} dBm"),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                final running = await FlutterForegroundTask.isRunningService;
                if (running) {
                  await FlutterForegroundTask.stopService();
                } else {
                  await FlutterForegroundTask.startService(
                    notificationTitle: 'WiFi Monitor Running',
                    notificationText: 'Scanning WiFi continuously',
                    callback: wifiScanTask,
                    notificationButtons: const [
                      NotificationButton(id: 'stop', text: 'Stop'),
                      NotificationButton(id: 'scan', text: 'Scan Now'),
                    ],
                  );
                }
              },
              child: const Text(
                "Toggle Background Service",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
