import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user_list_controller.dart';
import '../../helper/core/base/app_base_view.dart';

class UserListScreen extends AppBaseView<UserListController> {
  const UserListScreen({super.key});

  @override
  Widget buildView() => _buildScaffold();

  Scaffold _buildScaffold() => Scaffold(
    appBar: AppBar(
      title: const Text('User List'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: controller.onLogout,
          tooltip: 'Logout',
        ),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final users = controller.filteredUsers;

      if (users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.searchQuery.value.isEmpty
                    ? Icons.people_outline
                    : Icons.search_off,
                size: 64,
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'No users found.'
                    : 'No users match your search.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search users by email...',
                hintStyle: TextStyle(
                  color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: Theme.of(
                  Get.context!,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      Get.context!,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      Get.context!,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(Get.context!).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          // Users list
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userData = user.data();
                final email = userData['email']?.toString() ?? 'Unknown';
                final name = userData['name']?.toString() ?? '';
                final photoUrl = userData['photoUrl']?.toString() ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            email.isNotEmpty ? email[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  title: Text(
                    name.isNotEmpty ? name : email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: name.isNotEmpty
                      ? Text(
                          email,
                          style: TextStyle(
                            color: Theme.of(
                              Get.context!,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  onTap: () => controller.onUserTap(user),
                );
              },
            ),
          ),
        ],
      );
    }),
  );
}
