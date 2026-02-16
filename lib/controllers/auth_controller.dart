import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/employee.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var employee = Rxn<Employee>();

  final GetStorage _storage = GetStorage();

  // Placeholder URL
  final String _loginUrl = 'https://n8n.la-renting.com/webhook/employee-login';

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    if (_storage.hasData('token')) {
      isLoggedIn.value = true;
      // Optionally restore employee data if stored, or fetch profile
      // For this MVP, we might need to store employee name too to show in dashboard
      final savedName = _storage.read('employee_name');
      if (savedName != null) {
        // Create a partial employee object or just store name separately
        // For now, let's assume we proceed to dashboard
      }
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // Un-comment when real URL is ready
      
      final response = await http.post(
        Uri.parse(_loginUrl),
        body: {'email': email, 'password': password},
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
           Get.snackbar('Error', 'Server returned empty response');
           return;
        }

        final data = json.decode(response.body);
        
        // Handle case where n8n returns a list wrapper [ { ... } ]
        Map<String, dynamic> jsonResponse;
        if (data is List) {
          if (data.isNotEmpty) {
            jsonResponse = data.first;
          } else {
             Get.snackbar('Error', 'Server returned empty list');
             return;
          }
        } else {
          jsonResponse = data;
        }

        final loginResponse = LoginResponse.fromJson(jsonResponse);

        if (loginResponse.success) {
          _saveSession(loginResponse);
          Get.offAll(() => DashboardView());
        } else {
          Get.snackbar('Login Failed', 'Invalid credentials');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.remove('token');
    _storage.remove('employee_name');
    isLoggedIn.value = false;
    employee.value = null;
    Get.offAll(() => LoginView());
  }

  void _saveSession(LoginResponse response) {
    _storage.write('token', response.token);
    _storage.write('employee_name', response.employee.name);
    _storage.write('employee_email', response.employee.email);
    employee.value = response.employee;
    isLoggedIn.value = true;
  }
}
