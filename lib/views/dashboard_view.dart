import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => dashboardController.fetchDashboardData(),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final summary = dashboardController.summary.value;
        if (summary == null) {
          return Center(child: Text('No data available'));
        }

        final employeeName = authController.employee.value?.name ?? 'Employee';

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $employeeName',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Pending Jobs',
                      summary.pendingJobs.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Hours (Month)',
                      summary.totalHoursThisMonth.toString(),
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                 children: [
                   Expanded(
                    child: _buildSummaryCard(
                      'Total Hours',
                      summary.totalHoursAllTime.toString(),
                      Icons.history,
                      Colors.green,
                    ),
                  ),
                 ],
              ),
              SizedBox(height: 32),
              Text(
                'Upcoming Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dashboardController.upcomingJobs.length,
                itemBuilder: (context, index) {
                  final job = dashboardController.upcomingJobs[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                job.date,
                                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              Chip(
                                label: Text(job.status, style: TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            job.customerName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.address,
                                  style: TextStyle(color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                               Icon(Icons.timer, size: 16, color: Colors.grey),
                               SizedBox(width: 4),
                               Text('${job.hours} hours', style: TextStyle(color: Colors.grey[700])),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              Text(
                'Invoices',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dashboardController.recentInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = dashboardController.recentInvoices[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${invoice.invoiceNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                invoice.issueDate,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            invoice.customerName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse(invoice.invoiceLink);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                Get.snackbar('Error', 'Could not open invoice link',
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.description, size: 18, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'View Invoice',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
