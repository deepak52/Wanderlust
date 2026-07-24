// chat_screen.dart
// Chat Screen - Rebuilt from Wanderlust ChatScreen using Agro-Prod architecture
// Uses ChatController, MessageBubble, MessagesListView, MessageInputField
// Contains NO business logic - only UI building and action forwarding

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/chat_controller.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../helper/widget/common_widget.dart';
import '../../widgets/chat/messages_list_view.dart';
import '../../widgets/chat/message_input_field.dart';

class ChatScreen extends AppBaseView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget buildView() => Obx(() => _widgetView());

  Scaffold _widgetView() => appScaffold(
    appBar: customAppBar(
      controller.hasSelectedMessage ? '1 selected' : 'Chat',
      actions:
          controller.hasSelectedMessage
              ? _buildSelectionActions()
              : _buildDefaultActions(),
    ),
    body: _buildBody(),
    resizeToAvoidBottomInset: true,
    bottomSafe: false,
  );

  List<Widget> _buildSelectionActions() {
    return [
      if (controller.isSelectedMessageMine)
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          onPressed:
              () => controller.startEdit(controller.selectedMessageId.value),
        ),
      if (controller.isSelectedMessageMine)
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed:
              () =>
                  controller.deleteMessage(controller.selectedMessageId.value),
        ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: controller.clearSelection,
      ),
    ];
  }

  List<Widget> _buildDefaultActions() {
    return [
      PopupMenuButton<String>(
        onSelected: (value) {
          // Handle menu actions if needed
        },
        itemBuilder:
            (context) => const [
              PopupMenuItem(value: 'clear_chat', child: Text('Clear Chat')),
              PopupMenuItem(value: 'block_user', child: Text('Block User')),
            ],
      ),
    ];
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: MessagesListView(
            messages: controller.messages,
            currentUserId: controller.currentUserId,
            selectedMessageId: controller.selectedMessageId.value,
            onMessageTap: controller.toggleSelection,
            onDelete: controller.deleteMessage,
            onEdit: controller.startEdit,
            buildStatusIcon: controller.buildStatusIcon,
            reverse: true,
          ),
        ),

        // Editing indicator
        if (controller.isEditing) _buildEditingBanner(),

        // Reply indicator
        if (controller.isReplying) _buildReplyBanner(),

        // Message input field
        MessageInputField(
          controller: controller.messageController,
          onSend: controller.sendMessage,
          hintText:
              controller.isEditing
                  ? 'Edit your message...'
                  : 'Type a message...',
          enabled: !controller.isSending.value,
        ),
      ],
    );
  }

  Widget _buildEditingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border(left: BorderSide(color: Colors.orange, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Editing message...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColorHelper.primaryTextColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.cancelEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to: ${controller.replyToText.value}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColorHelper.primaryTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.clearReply,
          ),
        ],
      ),
    );
  }
}
