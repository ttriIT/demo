import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../widgets/user_avatar.dart';
import 'add_friend_screen.dart';

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
                      Icon(Icons.people_outline, size: 80, color: AppColors.grey),
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
                        style: const TextStyle(fontSize: 13, color: AppColors.grey),
                      ),
                    );
                  },
                ),

          // Friend Requests Tab
          friendsProvider.pendingRequests.isEmpty
              ? const Center(
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: AppColors.grey),
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
                    return FutureBuilder(
                      future: context
                          .read<FriendsProvider>()
                          .searchUsers(request.fromUserId),
                      builder: (context, snapshot) {
                        // Simple placeholder while loading
                        return ListTile(
                          leading: const UserAvatar(
                            name: 'User',
                            size: 50,
                          ),
                          title: Text('Friend Request'),
                          subtitle: Text('ID: ${request.fromUserId.substring(0, 8)}...'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await friendsProvider.acceptFriendRequest(
                                    request.id,
                                    authProvider.currentUser!.id,
                                    request.fromUserId,
                                  );
                                },
                                child: const Text(AppStrings.accept),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await friendsProvider.declineFriendRequest(
                                    request.id,
                                  );
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
