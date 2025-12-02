/// App configuration constants - TEMPLATE FILE
/// Copy this file to app_constants.dart and fill in your credentials
class AppConstants {
  AppConstants._();
  
  // Appwrite Configuration
  // Get these from https://cloud.appwrite.io
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId = 'YOUR_PROJECT_ID'; // Replace with your project ID
  
  // Appwrite Collections
  static const String databaseId = 'main_db';
  static const String usersCollectionId = 'users';
  static const String messagesCollectionId = 'messages';
  static const String friendRequestsCollectionId = 'friend_requests';
  
  // ZegoCloud Configuration
  // Get these from https://www.zegocloud.com
  static const int zegoAppId = 0; // Replace with your App ID (number)
  static const String zegoAppSign = 'YOUR_APP_SIGN'; // Replace with your App Sign
  
  // Pagination
  static const int messagesPageSize = 50;
  static const int friendsPageSize = 50;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double avatarSize = 50.0;
  static const double smallAvatarSize = 35.0;
  static const double largeAvatarSize = 80.0;
  
  // Animation Duration
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
