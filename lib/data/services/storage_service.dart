import 'dart:io';
import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/constants/app_constants.dart';

/// Storage service for uploading files to Appwrite
class StorageService {
  final _appwrite = AppwriteService();
  
  // Storage bucket ID for avatars (should be created in Appwrite console)

  /// Upload avatar image
  /// Returns the file URL if successful
  Future<String> uploadAvatar(File imageFile, String userId) async {
    try {
      // Upload file to Appwrite Storage
      final file = await _appwrite.storage.createFile(
        bucketId: AppConstants.avatarBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: 'avatar_$userId.jpg',
        ),
        permissions: [
          Permission.read(Role.any()),
        ],
      );

      // Get file URL
      final fileUrl = _appwrite.storage.getFileView(
        bucketId: AppConstants.avatarBucketId,
        fileId: file.$id,
      );

      return fileUrl.toString();
    } catch (e) {
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }

  /// Delete avatar image
  Future<void> deleteAvatar(String fileId) async {
    try {
      await _appwrite.storage.deleteFile(
        bucketId: AppConstants.avatarBucketId,
        fileId: fileId,
      );
    } catch (e) {
      // Silently fail - non-critical
      print('Failed to delete avatar: ${e.toString()}');
    }
  }
}

