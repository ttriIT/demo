import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/user_avatar.dart';
import 'chat_detail_screen.dart';

/// Chat list screen showing all conversations
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.chats,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: friendsProvider.friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noFriends,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add friends to start chatting',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: friendsProvider.friends.length,
              itemBuilder: (context, index) {
                final friend = friendsProvider.friends[index];
                return ListTile(
                  leading: UserAvatar(
                    imageUrl: friend.avatarUrl,
                    name: friend.name,
                    showOnlineIndicator: true,
                    isOnline: friend.isOnline,
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormatter.formatLastSeen(friend.lastSeen),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          friend: friend,
                          currentUserId: authProvider.currentUser!.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
