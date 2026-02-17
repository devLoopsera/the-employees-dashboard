import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/dashboard_data.dart';

class DashboardController extends GetxController {
  var isLoading = false.obs;
  var summary = Rxn<DashboardSummary>();
  var upcomingJobs = <Job>[].obs;
  var recentJobs = <Job>[].obs;
  var completedJobs = <Job>[].obs;
  var pendingJobs = <Job>[].obs;
  var runningJobs = <Job>[].obs;
  var cancelledJobs = <Job>[].obs;
  var recentInvoices = <Invoice>[].obs;

  // Pagination state: number of visible items for each category
  var visibleCompletedCount = 5.obs;
  var visiblePendingCount = 5.obs;
  var visibleRunningCount = 5.obs;
  var visibleCancelledCount = 5.obs;

  final GetStorage _storage = GetStorage();

  // Placeholder URL - replace with actual endpoint
  final String _dashboardUrl = 'https://n8n.la-renting.com/webhook/employee-dashboard';

  @override
  void onInit() {
    super.onInit();
    print('DashboardController initialized');
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    print('Fetching dashboard data from: $_dashboardUrl');
    isLoading.value = true;
    try {
      // final token = _storage.read('token'); // Unused for now
      // In a real app, you'd likely pass the token in headers
      // final headers = {'Authorization': 'Bearer $token'};
      
      // Simulating network delay for realistic feel
      // await Future.delayed(Duration(milliseconds: 500)); 

      // For now, since we don't have the real URL, I'll mock the response based on the requirement
      // OR use the http call if the user provided it (they said placeholders for now)
      
      // Un-comment this when real URL is available:
      final email = _storage.read('employee_email') ?? '';
      print('Fetching dashboard for email: $email');

      final response = await http.post(
        Uri.parse(_dashboardUrl),
        body: {'email': email},
      );
      
      print('Dashboard Status Code: ${response.statusCode}');
      print('Dashboard Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
           final data = json.decode(response.body);
           
           Map<String, dynamic> jsonResponse;
           if (data is List) {
             if (data.isNotEmpty) {
               jsonResponse = data.first;
             } else {
               return; // Empty list
             }
           } else {
             jsonResponse = data;
           }

           final dashboardResponse = DashboardResponse.fromJson(jsonResponse);
           if (dashboardResponse.success) {
             summary.value = dashboardResponse.summary;
             upcomingJobs.value = dashboardResponse.upcomingJobs;
             recentJobs.value = dashboardResponse.recentJobs;
             completedJobs.value = dashboardResponse.completedJobs;
             pendingJobs.value = dashboardResponse.pendingJobs;
             runningJobs.value = dashboardResponse.runningJobs;
             cancelledJobs.value = dashboardResponse.cancelledJobs;
             recentInvoices.value = dashboardResponse.recentInvoices;
             
             // Reset pagination when data is refreshed
             resetPagination();
           }
        }
      } else {
        Get.snackbar('Error', 'Failed to load dashboard data');
      }


    } catch (e) {
      print('Error fetching dashboard: $e');
      print('If you are running on Web and see XMLHttpRequest error, this is likely a CORS issue.');
      print('Check your browser developer console (F12) for more details.');
      Get.snackbar('Error', 'An error occurred. Check console for details.');
    } finally {
      isLoading.value = false;
    }
  }

  void resetPagination() {
    visibleCompletedCount.value = 5;
    visiblePendingCount.value = 5;
    visibleRunningCount.value = 5;
    visibleCancelledCount.value = 5;
  }

  void loadMoreCompleted() => visibleCompletedCount.value += 5;
  void loadMorePending() => visiblePendingCount.value += 5;
  void loadMoreRunning() => visibleRunningCount.value += 5;
  void loadMoreCancelled() => visibleCancelledCount.value += 5;
}
