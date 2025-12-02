import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
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

  /// Sign up with email, password, and name
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
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
  Future<void> signOut() async {
    _setLoading(true);
    try {
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
      _currentUser = await _authService.getCurrentUser();
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

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
