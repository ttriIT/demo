import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import 'call_provider.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in with email and password
  Future<bool> signIn(String email, String password, {CallProvider? callProvider}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      
      // Initialize ZegoUIKit after successful login
      if (callProvider != null && _currentUser != null) {
        try {
          await callProvider.initialize(
            userId: _currentUser!.id,
            userName: _currentUser!.name,
          );
        } catch (e) {
          print('Failed to initialize ZegoUIKit: $e');
        }
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email, password, and name (does not auto-login)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      // Don't set _currentUser, user needs to login after registration
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut({CallProvider? callProvider}) async {
    _setLoading(true);
    try {
      // Uninitialize ZegoUIKit before signing out
      if (callProvider != null) {
        try {
          await callProvider.uninitialize();
        } catch (e) {
          print('Failed to uninitialize ZegoUIKit: $e');
        }
      }
      
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
      } else {
        _currentUser = null;
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar(File imageFile) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final avatarUrl = await _storageService.uploadAvatar(
        imageFile,
        _currentUser!.id,
      );
      return avatarUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    try {
      await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        avatarUrl: avatarUrl,
      );
      
      // Refresh user data
      await refreshUser();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Failed to refresh user: ${e.toString()}');
    }
  }

  Timer? _inactivityTimer;
  bool _isActivityStatusEnabled = true;

  bool get isActivityStatusEnabled => _isActivityStatusEnabled;

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    // Set offline when disposing auth provider (app close/logout)
    if (_currentUser != null) {
      _authService.updateProfile(
        userId: _currentUser!.id,
        isOnline: false,
        lastSeen: DateTime.now(),
      );
    }
    super.dispose();
  }

  /// Toggle activity status
  void toggleActivityStatus(bool enabled) {
    _isActivityStatusEnabled = enabled;
    if (enabled) {
      resetInactivityTimer();
    } else {
      _inactivityTimer?.cancel();
      _setOnlineStatus(false);
    }
    notifyListeners();
  }

  /// Reset inactivity timer
  void resetInactivityTimer() {
    if (!_isActivityStatusEnabled || _currentUser == null) return;

    // Set online if not already
    _setOnlineStatus(true);

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 4), () {
      _setOnlineStatus(false);
    });
  }

  /// Helper to set online status in DB
  Future<void> _setOnlineStatus(bool isOnline) async {
    if (_currentUser == null) return;

    // Skip if status matches current state to avoid DB writes
    // However, we track this locally via _currentUser.isOnline ideally,
    // but here we just send the update.
    
    try {
      await _authService.updateProfile(
        userId: _currentUser!.id,
        isOnline: isOnline,
        lastSeen: isOnline ? null : DateTime.now(),
      );
      
      // Update local state partially
      // Ideally we should reload user or copyWith, but for perf we might skip
      // assuming the DB update is fire-and-forget for status.
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
