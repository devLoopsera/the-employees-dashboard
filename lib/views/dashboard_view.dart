import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_data.dart';
import '../widgets/app_sidebar.dart';
import 'profile_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends StatelessWidget {
  final String? initialSection;
  DashboardView({super.key, this.initialSection});

  final AuthController authController = Get.find<AuthController>();

  final ScrollController _scrollController = ScrollController();
  final _runningKey = GlobalKey();
  final _pendingKey = GlobalKey();
  final _completedKey = GlobalKey();
  final _cancelledKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF309278);

    if (initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Wait a bit for layout and data to be ready
        Future.delayed(const Duration(milliseconds: 300), () {
          if (initialSection == 'Running') _scrollToSection(_runningKey);
          if (initialSection == 'Pending') _scrollToSection(_pendingKey);
          if (initialSection == 'Completed') _scrollToSection(_completedKey);
          if (initialSection == 'Cancelled') _scrollToSection(_cancelledKey);
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Sidebar
          AppSidebar(
            activeItem: 'Dashboard',
            brandColor: brandColor,
            onSectionTap: (section) {
              if (section == 'Profile') {
                Get.to(() => ProfileView());
              } else if (section == 'Running') {
                _scrollToSection(_runningKey);
              } else if (section == 'Pending') {
                _scrollToSection(_pendingKey);
              } else if (section == 'Completed') {
                _scrollToSection(_completedKey);
              } else if (section == 'Cancelled') {
                _scrollToSection(_cancelledKey);
              }
            },
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildMainHeader(brandColor),
                Expanded(
                  child: Obx(() {
                    if (dashboardController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final summary = dashboardController.summary.value;
                    if (summary == null) {
                      return const Center(child: Text('No data available'));
                    }

                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContentHeader(),
                          const SizedBox(height: 32),
                          _buildJobSection(
                            'Running Jobs',
                            dashboardController.runningJobs,
                            dashboardController.visibleRunningCount,
                            dashboardController.loadMoreRunning,
                            brandColor,
                            key: _runningKey,
                          ),
                          const SizedBox(height: 24),
                          _buildJobSection(
                            'Pending Jobs',
                            dashboardController.pendingJobs,
                            dashboardController.visiblePendingCount,
                            dashboardController.loadMorePending,
                            Colors.orange,
                            key: _pendingKey,
                          ),
                          const SizedBox(height: 24),
                          _buildJobSection(
                            'Completed Jobs',
                            dashboardController.completedJobs,
                            dashboardController.visibleCompletedCount,
                            dashboardController.loadMoreCompleted,
                            Colors.green,
                            key: _completedKey,
                          ),
                          const SizedBox(height: 24),
                          _buildJobSection(
                            'Cancelled Jobs',
                            dashboardController.cancelledJobs,
                            dashboardController.visibleCancelledCount,
                            dashboardController.loadMoreCancelled,
                            Colors.red,
                            key: _cancelledKey,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMainHeader(Color brandColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Larenting Group LLC / Max Co-Host',
                  style: TextStyle(fontSize: 24, color: Color(0xFF309278), fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: double.infinity,
                  color: brandColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          _buildProfileDropdown(brandColor),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown(Color brandColor) {
    final email = authController.employee.value?.email ?? 'info@max.com';
    final role = 'Employee'; // Default role as it's not in the base Employee login model

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'profile') {
          Get.to(() => ProfileView());
        } else if (value == 'logout') {
          authController.logout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              _buildUserAvatarWithStatus(brandColor, radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4B5563)),
                  ),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.power_settings_new, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              const Text(
                'Abmelden',
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 16),
              ),
            ],
          ),
        ),
      ],
      child: _buildUserAvatarWithStatus(brandColor),
    );
  }

  Widget _buildUserAvatarWithStatus(Color brandColor, {double radius = 20}) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person, color: Colors.grey, size: radius * 1.2),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: radius * 0.6,
            height: radius * 0.6,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentHeader() {
    final employeeName = authController.employee.value?.name ?? 'Employee';
    return Row(
      children: [
        Text(
          employeeName,
          style: const TextStyle(fontSize: 24, color: Color(0xFF4B5563), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


  Widget _buildJobSection(
    String title,
    RxList<Job> jobs,
    RxInt visibleCount,
    VoidCallback onLoadMore,
    Color categoryColor, {
    Key? key,
  }) {
    return Obx(() {
      if (jobs.isEmpty) return const SizedBox.shrink();

      final displayCount = visibleCount.value > jobs.length ? jobs.length : visibleCount.value;
      final displayJobs = jobs.take(displayCount).toList();

      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: categoryColor),
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
