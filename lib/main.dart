import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'controller/wifi_controller.dart';
import 'screens/wifi_screen.dart';
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final controller = WifiController();
    await controller.scanAndCheck();
    return Future.value(true);
  });
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerPeriodicTask(
    "wifiScanTask",
    "wifiScanBackground",
    frequency: const Duration(minutes: 15),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  WifiScannerApp (),
    );
  }
}

