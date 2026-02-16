import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth_controller.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize AuthController globally
    final AuthController authController = Get.put(AuthController());

    return GetMaterialApp(
      title: 'Cleaning Dashboard',
      theme: ThemeData(
        fontFamily: 'Roboto', // Using default for now, can be changed
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Obx(() {
        // Simple routing based on login status
        return authController.isLoggedIn.value ? DashboardView() : LoginView();
      }),
    );
  }
}
