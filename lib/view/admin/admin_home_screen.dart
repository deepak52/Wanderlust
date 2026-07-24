import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/admin_home_controller.dart';

class AdminHomeScreen extends GetView<AdminHomeController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: controller.onLogout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDashboardButton(
                icon: Icons.list_alt,
                label: 'View Tour Question Responses',
                onTap: controller.onViewResponses,
              ),
              const SizedBox(height: 16),
              _buildDashboardButton(
                icon: Icons.chat,
                label: 'Chat with Users',
                onTap: controller.onViewUserList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
