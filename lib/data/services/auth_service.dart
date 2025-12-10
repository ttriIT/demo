import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../core/services/appwrite_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Authentication service using Appwrite
class AuthService {
  final _appwrite = AppwriteService();

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      // Create session
      try {
        await _appwrite.account.createEmailPasswordSession(
          email: email,
          password: password,
        );
      } on AppwriteException catch (e) {
        if (e.type == 'user_session_already_exists') {
          // Session already exists, ignore and proceed
        } else {
          rethrow;
        }
      }

      // Get current user
      return await getCurrentUser();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign up with email, password, and name
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create account
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create user document in database
      await _appwrite.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: user.$id,
        data: {
          'email': email,
          'name': name,
          'avatarUrl': null,
          'friends': [],
          'createdAt': DateTime.now().toIso8601String(),
          'lastSeen': DateTime.now().toIso8601String(),
          'isOnline': true,
        },
      );

      // Sign in after registration
      try {
        await _appwrite.account.createEmailPasswordSession(
          email: email,
          password: password,
        );
      } on AppwriteException catch (e) {
        if (e.type == 'user_session_already_exists') {
          // Session already exists, ignore and proceed
        } else {
          rethrow;
        }
      }

      return await getCurrentUser();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Update online status
      final user = await _appwrite.account.get();
      await updateUserStatus(user.$id, false);

      // Delete current session
      await _appwrite.account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    try {
      final account = await _appwrite.account.get();
      
      // Get user document from database
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: account.$id,
      );

      // Update online status
      await updateUserStatus(account.$id, true);

      return UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await _appwrite.account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update user online status
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: {
          'isOnline': isOnline,
          'lastSeen': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silently fail - non-critical operation
      print('Failed to update user status: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (isOnline != null) data['isOnline'] = isOnline;
      if (lastSeen != null) data['lastSeen'] = lastSeen.toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
}
