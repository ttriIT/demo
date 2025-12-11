import 'dart:io';
import 'package:appwrite/appwrite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/appwrite_service.dart';

/// Storage service for file uploads
class StorageService {
  final AppwriteService _appwrite = AppwriteService();

  /// Upload avatar image
  Future<void> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: {'avatarUrl': avatarUrl},
      );
    } catch (e) {
      throw Exception('Failed to update avatar: ${e.toString()}');
    }
  }

  Future<bool> _checkPermission() async {
    // simplified permission check for now
    return true;
  }
}
