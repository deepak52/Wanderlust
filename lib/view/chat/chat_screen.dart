import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/chat_controller.dart';
import '../../helper/adventure_assets.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../widgets/chat/message_input_field.dart';
import '../../widgets/chat/messages_list_view.dart';

class ChatScreen extends AppBaseView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget buildView() {
    developer.log(
        '🔍 CONTROLLER_IDENTITY ChatScreen.buildView: controller.identityHashCode=${identityHashCode(controller)}');

    return Builder(
      builder: (context) => _widgetView(context),
    );
  }

  Widget _widgetView(BuildContext context) {
    return PopScope(
      canPop: controller.isAdmin,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColorHelper.chatSurfaceDark,
        appBar: _buildCustomWanderlustAppBar(context),
        body: Stack(
          children: [
            // 1. Mountain/river background with dark atmospheric overlay
            Positioned.fill(
              child: Image.asset(
                AdventureAssets.revealMapTexture,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: AppColorHelper.chatSurfaceDark.withValues(alpha: 0.86),
              ),
            ),

            // 2. Chat Stream & Input Body
            Positioned.fill(
              child: _buildBody(context),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  PreferredSizeWidget _buildCustomWanderlustAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorHelper.chatSurfaceDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          color: AppColorHelper.chatDivider,
          height: 1,
          thickness: 1,
        ),
      ),
      leading: Center(
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 22,
            color: AppColorHelper.chatTextPrimary,
          ),
          onPressed: () {
            if (controller.hasSelectedMessage) {
              controller.clearSelection();
            } else if (controller.isAdmin) {
              Get.back();
            } else {
              controller.onWillPop();
            }
          },
        ),
      ),
      title: Obx(
        () => controller.hasSelectedMessage
            ? Text(
                '1 selected',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColorHelper.chatTextPrimary,
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColorHelper.chatDeepTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: controller.isAdmin &&
                              controller.otherUserName.value.isNotEmpty
                          ? Text(
                              controller.otherUserName.value[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64D2C8),
                              ),
                            )
                          : const Icon(
                              Icons.terrain_rounded,
                              color: Color(0xFF64D2C8),
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.displayTitle,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: AppColorHelper.chatTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColorHelper.chatOnlineGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Online',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColorHelper.chatTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
      actions: [
        Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: controller.hasSelectedMessage
                ? _buildSelectionActions(context)
                : _buildDefaultActions(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActions(BuildContext context) {
    final selectedMsg = controller.selectedMessage;
    final isDeleted = selectedMsg?.deleted ?? false;

    return [
      if (!isDeleted)
        IconButton(
          icon: const Icon(Icons.reply_rounded, color: AppColorHelper.chatTextPrimary, size: 22),
          tooltip: 'Reply',
          onPressed: () {
            controller.startReply(controller.selectedMessageId.value);
          },
        ),
      if (controller.isSelectedMessageMine && !isDeleted)
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: AppColorHelper.chatTextPrimary, size: 21),
          tooltip: 'Edit',
          onPressed: () =>
              controller.startEdit(controller.selectedMessageId.value),
        ),
      if (controller.isSelectedMessageMine && !isDeleted)
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColorHelper.chatTextPrimary, size: 22),
          tooltip: 'Delete',
          onPressed: () =>
              controller.confirmDeleteMessage(context, controller.selectedMessageId.value),
        ),
      IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColorHelper.chatTextPrimary, size: 22),
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
            controller.lockEnabled.value
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            color: AppColorHelper.chatTextSecondary,
            size: 20,
          ),
          tooltip: controller.lockEnabled.value
              ? 'Disable Lock'
              : 'Enable Lock',
          onPressed: () => controller.toggleLock(context),
        ),
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColorHelper.chatTextSecondary, size: 20),
        color: AppColorHelper.chatSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColorHelper.chatDivider,
            width: 1,
          ),
        ),
        onSelected: (value) {
          if (value == 'toggle_lock') {
            controller.toggleLock(context);
          } else if (value == 'logout') {
            controller.logout();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'toggle_lock',
            child: Text(
              controller.lockEnabled.value ? 'Disable Lock' : 'Enable Lock',
              style: const TextStyle(color: AppColorHelper.chatTextPrimary, fontSize: 13.5),
            ),
          ),
          const PopupMenuItem(
            value: 'logout',
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontSize: 13.5),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: Obx(
            () => MessagesListView(
              messages: controller.messages.toList(),
              currentUserId: controller.currentUserId,
              selectedMessageId: controller.selectedMessageId.value,
              onMessageTap: controller.toggleSelection,
              onDelete: (msgId) => controller.confirmDeleteMessage(context, msgId),
              onEdit: controller.startEdit,
              onReply: controller.startReply,
              buildStatusIcon: controller.buildStatusIcon,
              reverse: true,
            ),
          ),
        ),

        // Editing indicator
        Obx(
          () => controller.isEditing
              ? _buildEditingBanner()
              : const SizedBox.shrink(),
        ),

        // Reply indicator
        Obx(
          () => controller.isReplying
              ? _buildReplyBanner()
              : const SizedBox.shrink(),
        ),

        // Message input field
        Obx(
          () => MessageInputField(
            controller: controller.messageController,
            onSend: controller.sendMessage,
            hintText: controller.isEditing
                ? 'Edit your message...'
                : 'Type a message...',
            enabled: !controller.isSending.value,
            isEditing: controller.isEditing,
          ),
        ),
      ],
    );
  }

  Widget _buildEditingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColorHelper.chatSurface,
        border: Border(
          left: BorderSide(color: AppColorHelper.warmGold, width: 3.5),
          top: BorderSide(color: AppColorHelper.chatDivider, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16, color: AppColorHelper.warmGold),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Editing message...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColorHelper.chatTextPrimary,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColorHelper.chatTextSecondary),
            onPressed: controller.cancelEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColorHelper.chatSurface,
        border: Border(
          left: BorderSide(color: AppColorHelper.chatPrimaryTeal, width: 3.5),
          top: BorderSide(color: AppColorHelper.chatDivider, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16, color: AppColorHelper.chatPrimaryTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to: ${controller.replyToText.value}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColorHelper.chatTextPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColorHelper.chatTextSecondary),
            onPressed: controller.clearReply,
          ),
        ],
      ),
    );
  }
}
