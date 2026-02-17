import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('My Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.fetchProfile(),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return Center(child: Text('No profile data available'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(profile),
              SizedBox(height: 24),
              _buildSectionTitle('Personal Information'),
              _buildInfoCard([
                _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
                _buildInfoRow(Icons.phone_outlined, 'Phone', profile.phone),
                _buildInfoRow(Icons.location_on_outlined, 'Address', profile.address),
                _buildInfoRow(Icons.public_outlined, 'Country', profile.country),
              ]),
              SizedBox(height: 24),
              _buildSectionTitle('Work Details'),
              _buildInfoCard([
                _buildInfoRow(Icons.work_outline, 'Role', profile.role),
                _buildInfoRow(Icons.payments_outlined, 'Hourly Rate', '€${profile.hourlyRate}'),
                _buildInfoRow(Icons.event_available_outlined, 'Availability', profile.availability),
                _buildInfoRow(Icons.info_outline, 'Status', profile.status, 
                  color: profile.status == 'Active' ? Colors.green : Colors.orange),
              ]),
              SizedBox(height: 24),
              _buildSectionTitle('Languages & Social'),
              _buildInfoCard([
                _buildInfoRow(Icons.language, 'Primary Language', profile.language1),
                _buildInfoRow(Icons.language, 'Secondary Language', profile.language2),
                _buildInfoRow(Icons.chat_bubble_outline, 'Telegram Chat ID', profile.telegramChatId),
              ]),
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(dynamic profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            child: Text(
              profile.name[0].toUpperCase(),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
          SizedBox(height: 16),
          Text(
            profile.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            profile.role,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
            child: Icon(icon, size: 20, color: Colors.blueAccent),
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
