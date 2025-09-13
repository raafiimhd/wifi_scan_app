import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wifi_controller.dart';

class WifiScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wifiController = Get.put(WifiController());
    return Scaffold(
      appBar: AppBar(title: Text("Wi-Fi Scanner")),
      body: Obx(() => ListView(
        children: wifiController.networks
            .map((n) => ListTile(
                  title: Text(n.ssid),
                  subtitle: Text("RSSI: ${n.level}"),
                ))
            .toList(),
      )),
    );
  }
}