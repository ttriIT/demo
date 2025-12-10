import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/user_avatar.dart';
import 'add_friend_screen.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/user_model.dart';
import '../chat/chat_detail_screen.dart';

/// Friends screen with friends list and friend requests
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.friends,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFriendScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: AppStrings.allFriends),
            Tab(text: AppStrings.requests),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Friends Tab
          friendsProvider.friends.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 80, color: AppColors.grey),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.noFriends,
                        style: TextStyle(fontSize: 18, color: AppColors.grey),
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
                        friend.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          // Confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa bạn'),
                              content: Text(
                                  'Bạn có chắc chắn muốn xóa ${friend.name} khỏi danh sách bạn bè?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && mounted) {
                            final success = await friendsProvider.removeFriend(
                              authProvider.currentUser!.id,
                              friend.id,
                            );

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Removed ${friend.name} from friends'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        },
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

          // Friend Requests Tab
          friendsProvider.pendingRequests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 80, color: AppColors.grey),
                      SizedBox(height: 6),
                      Text(
                        AppStrings.noRequests,
                        style: TextStyle(fontSize: 18, color: AppColors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: friendsProvider.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendsProvider.pendingRequests[index];
                    return FutureBuilder<UserModel>(
                      future: DatabaseService().getUserById(request.fromUserId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            leading: const UserAvatar(
                              name: 'Loading...',
                              size: 50,
                            ),
                            title: const Text('Loading...'),
                            subtitle: const Text('Loading user information'),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return ListTile(
                            leading: const UserAvatar(
                              name: 'Unknown',
                              size: 50,
                            ),
                            title: const Text('Unknown User'),
                            subtitle: Text(
                                'ID: ${request.fromUserId.substring(0, 8)}...'),
                          );
                        }

                        final user = snapshot.data!;
                        return ListTile(
                          leading: UserAvatar(
                            imageUrl: user.avatarUrl,
                            name: user.name,
                            size: 50,
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final success =
                                      await friendsProvider.acceptFriendRequest(
                                    request.id,
                                    authProvider.currentUser!.id,
                                    request.fromUserId,
                                  );
                                  if (success && mounted) {
                                    // Refresh the entire screen to update both tabs
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Friend request accepted!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(AppStrings.accept),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final success = await friendsProvider
                                      .declineFriendRequest(
                                    request.id,
                                  );
                                  if (success && mounted) {
                                    // Remove the request from UI immediately
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Friend request declined'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                                child: const Text(AppStrings.decline),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
