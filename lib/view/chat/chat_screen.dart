// chat_screen.dart
// Chat Screen - Rebuilt from Wanderlust ChatScreen using Agro-Prod architecture
// Uses ChatController, MessageBubble, MessagesListView, MessageInputField
// Contains NO business logic - only UI building and action forwarding

import 'dart:developer' as developer;

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
  Widget buildView() {
    // CONTROLLER_IDENTITY_DEBUG: Log identityHashCode to verify single instance
    developer.log('🔍 CONTROLLER_IDENTITY ChatScreen.buildView: controller.identityHashCode=${identityHashCode(controller)}');
    // RXLIST_IDENTITY_DEBUG: Log identityHashCode of messages RxList
    developer.log('🔍 RXLIST_IDENTITY ChatScreen: controller.messages identityHashCode=${identityHashCode(controller.messages)}');
    return Obx(() {
      // Explicitly read messages RxList to register GetX dependency
      final messages = controller.messages;
      developer.log('🔍 OBX_REBUILD ChatScreen: messages.length=${messages.length}');
      return Builder(
        builder: (context) => _widgetView(context),
      );
    });
  }

  Widget _widgetView(BuildContext context) {
    return PopScope(
      canPop: controller.isAdmin,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.onWillPop();
        }
      },
      child: appScaffold(
        appBar: customAppBar(
          controller.hasSelectedMessage
              ? '1 selected'
              : (controller.isAdmin ? 'Admin Chat' : 'Chat'),
          actions:
              controller.hasSelectedMessage
                  ? _buildSelectionActions()
                  : _buildDefaultActions(context),
        ),
        body: _buildBody(),
        resizeToAvoidBottomInset: true,
        bottomSafe: false,
      ),
    );
  }

  List<Widget> _buildSelectionActions() {
    final selectedMsg = controller.selectedMessage;
    final isDeleted = selectedMsg?.deleted ?? false;

    return [
      if (!isDeleted)
        IconButton(
          icon: const Icon(Icons.reply, color: Colors.blue),
          tooltip: 'Reply',
          onPressed: () {
            controller.startReply(controller.selectedMessageId.value);
            controller.clearSelection();
          },
        ),
      if (controller.isSelectedMessageMine && !isDeleted)
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          tooltip: 'Edit',
          onPressed:
              () => controller.startEdit(controller.selectedMessageId.value),
        ),
      if (controller.isSelectedMessageMine && !isDeleted)
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete',
          onPressed:
              () =>
                  controller.deleteMessage(controller.selectedMessageId.value),
        ),
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Cancel',
        onPressed: controller.clearSelection,
      ),
    ];
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      Obx(
        () => IconButton(
          icon: Icon(
            controller.lockEnabled.value ? Icons.lock : Icons.lock_open,
            color: controller.lockEnabled.value ? Colors.amber : Colors.white,
          ),
          tooltip: controller.lockEnabled.value
              ? 'Disable Lock'
              : 'Enable Lock',
          onPressed: () => controller.toggleLock(context),
        ),
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'toggle_lock') {
            controller.toggleLock(context);
          } else if (value == 'logout') {
            controller.logout();
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'toggle_lock',
                child: Text(
                  controller.lockEnabled.value ? 'Disable Lock' : 'Enable Lock',
                ),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
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
            messages: controller.messages.toList(),
            currentUserId: controller.currentUserId,
            selectedMessageId: controller.selectedMessageId.value,
            onMessageTap: controller.toggleSelection,
            onDelete: controller.deleteMessage,
            onEdit: controller.startEdit,
            onReply: controller.startReply,
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
