import 'dart:io';
import 'package:appwrite/appwrite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/appwrite_service.dart';

/// Storage service for file uploads
class StorageService {
  final AppwriteService _appwrite = AppwriteService();

  /// Upload avatar image
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final result = await _appwrite.storage.createFile(
        bucketId: '67584144002621980862', // TODO: Move to AppConstants
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: 'avatar_$userId.jpg'),
      );

      return 'https://cloud.appwrite.io/v1/storage/buckets/67584144002621980862/files/${result.$id}/view?project=692ea196003c16a4b465';
    } catch (e) {
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }

  Future<bool> _checkPermission() async {
    // simplified permission check for now
    return true;
  }
}
