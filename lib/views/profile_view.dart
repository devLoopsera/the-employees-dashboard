import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_sidebar.dart';
import 'dashboard_view.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final AuthController authController = Get.find<AuthController>();
  final brandColor = const Color(0xFF309278);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Sidebar
          AppSidebar(
            activeItem: 'Profile',
            brandColor: brandColor,
            onSectionTap: (section) {
              if (section == 'Dashboard') {
                Get.offAll(() => DashboardView());
              } else if (section != 'Profile') {
                Get.offAll(() => DashboardView(initialSection: section));
              }
            },
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildProfileHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final profile = controller.profile.value;
                    if (profile == null) {
                      return const Center(child: Text('No profile data available'));
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileInfo(profile),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Personal Information'),
                          _buildInfoCard([
                            _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
                            _buildInfoRow(Icons.phone_outlined, 'Phone', profile.phone),
                            _buildInfoRow(Icons.location_on_outlined, 'Address', profile.address),
                            _buildInfoRow(Icons.public_outlined, 'Country', profile.country),
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Work Details'),
                          _buildInfoCard([
                            _buildInfoRow(Icons.work_outline, 'Role', profile.role),
                            _buildInfoRow(Icons.payments_outlined, 'Hourly Rate', '€${profile.hourlyRate}'),
                            _buildInfoRow(Icons.event_available_outlined, 'Availability', profile.availability),
                            _buildInfoRow(Icons.info_outline, 'Status', profile.status, 
                              color: profile.status == 'Active' ? Colors.green : Colors.orange),
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Languages & Social'),
                          _buildInfoCard([
                            _buildInfoRow(Icons.language, 'Primary Language', profile.language1),
                            _buildInfoRow(Icons.language, 'Secondary Language', profile.language2),
                            _buildInfoRow(Icons.chat_bubble_outline, 'Telegram Chat ID', profile.telegramChatId),
                          ]),
                          const SizedBox(height: 32),
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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Settings',
                  style: TextStyle(fontSize: 24, color: brandColor, fontWeight: FontWeight.w400),
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
          IconButton(
            icon: Icon(Icons.refresh, color: brandColor),
            onPressed: () => controller.fetchProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: brandColor.withOpacity(0.1),
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: brandColor),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                profile.role,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (index < children.length - 1)
                Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey[100]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: brandColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.w500,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
