import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/friends_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/message_bubble.dart';
import '../call/video_call_screen.dart';

/// Chat detail screen for one-on-one conversation
class ChatDetailScreen extends StatefulWidget {
  final UserModel friend;
  final String currentUserId;

  const ChatDetailScreen({
    super.key,
    required this.friend,
    required this.currentUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadMessages(widget.currentUserId, widget.friend.id);
    chatProvider.subscribeToConversation(
        widget.currentUserId, widget.friend.id);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final text = _messageController.text.trim();
    _messageController.clear();

    await chatProvider.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.friend.id,
      text: text,
    );

    _scrollToBottom();
  }

  Future<void> _initiateVideoCall() async {
    final callProvider = context.read<CallProvider>();
    final authProvider = context.read<AuthProvider>();
    final friendsProvider = context.read<FriendsProvider>();

    if (authProvider.currentUser == null) return;

    // Get updated friend data
    final friend =
        friendsProvider.getFriendById(widget.friend.id) ?? widget.friend;

    // Generate consistent call ID (sorted to ensure same ID for both users)
    final userIds = [widget.currentUserId, friend.id]..sort();
    final callId = '${userIds[0]}_${userIds[1]}';

    try {
      await callProvider.sendCallInvitation(
        targetUser: friend,
        callId: callId,
        isVideoCall: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate call: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.unsubscribeFromConversation(
        widget.currentUserId, widget.friend.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final friendsProvider = context.watch<FriendsProvider>();
    final messages = chatProvider.getConversationMessages(
      widget.currentUserId,
      widget.friend.id,
    );

    // Get updated friend data from FriendsProvider if available
    final friend =
        friendsProvider.getFriendById(widget.friend.id) ?? widget.friend;
    final isOnline = friend.isOnline;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            UserAvatar(
              imageUrl: friend.avatarUrl,
              name: friend.name,
              size: 40,
              showOnlineIndicator: true,
              isOnline: isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isOnline ? 'Active now' : 'Offline',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.primaryBlue),
            onPressed: _initiateVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.noMessages,
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.senderId == widget.currentUserId;
                      return MessageBubble(
                        message: message,
                        isSender: isSender,
                      );
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkGrey
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.typeMessage,
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
