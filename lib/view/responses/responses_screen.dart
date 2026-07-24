import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/responses_controller.dart';
import '../../helper/core/base/app_base_view.dart';

class ResponsesScreen extends AppBaseView<ResponsesController> {
  const ResponsesScreen({super.key});

  @override
  Widget buildView() => _buildScaffold();

  Scaffold _buildScaffold() => Scaffold(
    appBar: AppBar(
      title: const Text('User Responses'),
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

      final responses = controller.filteredResponses;

      if (responses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'No responses found.'
                    : 'No responses match your search.',
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
                hintText: 'Search responses by email...',
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
          // Responses list
          Expanded(
            child: ListView.builder(
              itemCount: responses.length,
              itemBuilder: (context, index) {
                final response = responses[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text(
                    response.email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    response.answerText,
                    style: TextStyle(
                      color: Theme.of(
                        Get.context!,
                      ).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Response'),
                          content: Text(
                            'Are you sure you want to delete ${response.email}\'s responses?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        controller.deleteResponse(response);
                      }
                    },
                  ),
                  onTap: () => controller.onResponseTap(response),
                );
              },
            ),
          ),
        ],
      );
    }),
  );
}
