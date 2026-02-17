import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_data.dart';
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
                      'Running Jobs',
                      summary.runningJobs.toString(),
                      Icons.play_circle_outline,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Pending Jobs',
                      summary.pendingJobs.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: _buildSummaryCard(
                      'Completed Jobs',
                      summary.completedJobs.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Cancelled Jobs',
                      summary.cancelledJobs.toString(),
                      Icons.cancel_outlined,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Hours (Month)',
                      summary.totalHoursThisMonth.toString(),
                      Icons.calendar_month_outlined,
                      Colors.indigo,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Hours',
                      summary.totalHoursAllTime.toString(),
                      Icons.history,
                      Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(height: 32),
              _buildJobSection(
                'Running Jobs',
                dashboardController.runningJobs,
                dashboardController.visibleRunningCount,
                dashboardController.loadMoreRunning,
                Colors.blue,
              ),
              SizedBox(height: 24),
              _buildJobSection(
                'Pending Jobs',
                dashboardController.pendingJobs,
                dashboardController.visiblePendingCount,
                dashboardController.loadMorePending,
                Colors.orange,
              ),
              SizedBox(height: 24),
              _buildJobSection(
                'Completed Jobs',
                dashboardController.completedJobs,
                dashboardController.visibleCompletedCount,
                dashboardController.loadMoreCompleted,
                Colors.green,
              ),
              SizedBox(height: 24),
              _buildJobSection(
                'Cancelled Jobs',
                dashboardController.cancelledJobs,
                dashboardController.visibleCancelledCount,
                dashboardController.loadMoreCancelled,
                Colors.red,
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

  Widget _buildJobSection(
    String title,
    RxList<Job> jobs,
    RxInt visibleCount,
    VoidCallback onLoadMore,
    Color categoryColor,
  ) {
    return Obx(() {
      if (jobs.isEmpty) return SizedBox.shrink();

      final displayCount = visibleCount.value > jobs.length ? jobs.length : visibleCount.value;
      final displayJobs = jobs.take(displayCount).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...displayJobs.map((job) => _buildExpandableJobCard(job, categoryColor)),
          if (visibleCount.value < jobs.length)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: onLoadMore,
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('See More'),
                  style: TextButton.styleFrom(foregroundColor: categoryColor),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildExpandableJobCard(Job job, Color statusColor) {
    final isExpanded = false.obs;

    return Obx(() => Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Padding(
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.customerName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isExpanded.value ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          onPressed: () => isExpanded.toggle(),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
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
                        Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${job.hours} scheduled hours',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded.value)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Customer Schedule', 
                        '${job.customerStartTime ?? "N/A"} - ${job.customerStopTime ?? "N/A"}'),
                      SizedBox(height: 8),
                      _buildDetailRow('Employee Time', 
                        '${job.employeeStartTime ?? "N/A"} - ${job.employeeEndTime ?? "N/A"}'),
                      if (job.status == 'completed' && job.employeeTotalHours != null) ...[
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Actual Hours Done:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${job.employeeTotalHours} hours',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                      if (job.status == 'cancelled' && job.cancelledDateTime != null && job.cancelledDateTime!.isNotEmpty) ...[
                         SizedBox(height: 8),
                         _buildDetailRow('Cancelled On', job.cancelledDateTime!),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
