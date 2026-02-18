import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/auth_controller.dart';

class AppSidebar extends StatelessWidget {
  final String activeItem;
  final Function(String section)? onSectionTap;
  final Color brandColor;

  AppSidebar({
    super.key,
    required this.activeItem,
    this.onSectionTap,
    required this.brandColor,
  });

  final DashboardController dashboardController = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                  ),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSidebarItem('Dashboard', Icons.dashboard_outlined, activeItem == 'Dashboard', brandColor, onTap: () {
            if (activeItem != 'Dashboard') {
              onSectionTap?.call('Dashboard');
            }
          }),
          Obx(() => _buildSidebarItem(
                'Running (${dashboardController.runningJobs.length})',
                Icons.play_circle_outline,
                activeItem == 'Running',
                brandColor,
                onTap: () => onSectionTap?.call('Running'),
              )),
          Obx(() => _buildSidebarItem(
                'Pending (${dashboardController.pendingJobs.length})',
                Icons.pending_actions,
                activeItem == 'Pending',
                brandColor,
                onTap: () => onSectionTap?.call('Pending'),
              )),
          Obx(() => _buildSidebarItem(
                'Completed (${dashboardController.completedJobs.length})',
                Icons.check_circle_outline,
                activeItem == 'Completed',
                brandColor,
                onTap: () => onSectionTap?.call('Completed'),
              )),
          Obx(() => _buildSidebarItem(
                'Cancelled (${dashboardController.cancelledJobs.length})',
                Icons.cancel_outlined,
                activeItem == 'Cancelled',
                brandColor,
                onTap: () => onSectionTap?.call('Cancelled'),
              )),
          _buildSidebarItem('Profile', Icons.person_outline, activeItem == 'Profile', brandColor, onTap: () {
            if (activeItem != 'Profile') {
              onSectionTap?.call('Profile');
            }
          }),
          const Spacer(),
          _buildSidebarItem('Logout', Icons.logout, false, brandColor, onTap: () {
            authController.logout();
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, bool isActive, Color brandColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF3F4F6) : Colors.transparent,
          border: isActive ? Border(left: BorderSide(color: brandColor, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? brandColor : const Color(0xFF9BA3AF), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? brandColor : const Color(0xFF4B5563),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
