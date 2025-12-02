import 'package:appwrite/models.dart' as models;

/// User model representing app users
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final List<String> friends;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.friends,
    required this.createdAt,
    this.lastSeen,
    this.isOnline = false,
  });

  /// Create UserModel from Appwrite Document
  factory UserModel.fromDocument(models.Document doc) {
    return UserModel(
      id: doc.$id,
      email: doc.data['email'] as String? ?? '',
      name: doc.data['name'] as String? ?? 'Unknown',
      avatarUrl: doc.data['avatarUrl'] as String?,
      friends: List<String>.from(doc.data['friends'] as List? ?? []),
      createdAt: DateTime.parse(doc.data['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastSeen: doc.data['lastSeen'] != null 
          ? DateTime.parse(doc.data['lastSeen'] as String)
          : null,
      isOnline: doc.data['isOnline'] as bool? ?? false,
    );
  }

  /// Convert to Map for Appwrite Document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'friends': friends,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    List<String>? friends,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      friends: friends ?? this.friends,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
