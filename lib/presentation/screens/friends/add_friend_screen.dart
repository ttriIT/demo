import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/friend_request_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';

/// Add friend screen - search and send friend requests
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    final friendsProvider = context.read<FriendsProvider>();
    final authProvider = context.read<AuthProvider>();
    await friendsProvider.searchUsers(
      _searchController.text.trim(),
    );
    // Also load sent requests for the current user
    if (authProvider.currentUser != null) {
      await friendsProvider.loadSentRequests(authProvider.currentUser!.id);
    }

    if (!mounted) return;

    if (friendsProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendsProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (friendsProvider.searchResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy người dùng với email này'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addFriend),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _searchController,
              label: AppStrings.search,
              hint: 'Search by email...',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  friendsProvider.clearSearchResults();
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: AppStrings.search,
              onPressed: _onSearch,
              isLoading: friendsProvider.isLoading,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: friendsProvider.searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Search for friends by email',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: friendsProvider.searchResults.length,
                      itemBuilder: (context, index) {
                        final user = friendsProvider.searchResults[index];
                        final isCurrentUser =
                            user.id == authProvider.currentUser?.id;
                        final isFriend =
                            friendsProvider.friends.any((f) => f.id == user.id);

                        // Check if we already sent a request to this user
                        // We look for a request where toUserId == user.id
                        final sentRequest =
                            friendsProvider.sentRequests.firstWhere(
                          (r) => r.toUserId == user.id,
                          orElse: () => FriendRequestModel(
                              id: '',
                              fromUserId: '',
                              toUserId: '',
                              timestamp: DateTime.now(),
                              status:
                                  FriendRequestStatus.accepted // Dummy status
                              ),
                        );
                        final hasSentRequest = sentRequest.id.isNotEmpty &&
                            sentRequest.status == FriendRequestStatus.pending;

                        return ListTile(
                          leading: UserAvatar(
                            imageUrl: user.avatarUrl,
                            name: user.name,
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            user.email,
                            style: const TextStyle(color: AppColors.grey),
                          ),
                          trailing: isCurrentUser
                              ? const Text('You',
                                  style: TextStyle(color: AppColors.grey))
                              : isFriend
                                  ? const Text('Friend',
                                      style:
                                          TextStyle(color: AppColors.success))
                                  : hasSentRequest
                                      ? TextButton(
                                          onPressed: () async {
                                            final success =
                                                await friendsProvider
                                                    .cancelFriendRequest(
                                                        sentRequest.id,
                                                        authProvider
                                                            .currentUser!.id);
                                            if (success && context.mounted) {
                                              // Reload sent requests to update UI
                                              await friendsProvider.loadSentRequests(authProvider.currentUser!.id);
                                              setState(() {}); // Refresh UI
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Request cancelled'),
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Cancel request',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      : TextButton(
                                          onPressed: () async {
                                            final success =
                                                await friendsProvider
                                                    .sendFriendRequest(
                                              authProvider.currentUser!.id,
                                              user.id,
                                            );
                                            if (success && context.mounted) {
                                              // Reload sent requests to update UI
                                              await friendsProvider.loadSentRequests(authProvider.currentUser!.id);
                                              setState(() {}); // Refresh UI
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Friend request sent!'),
                                                  backgroundColor:
                                                      AppColors.success,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                              AppStrings.sendRequest),
                                        ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
