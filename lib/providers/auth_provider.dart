import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sales_bets/core/services/auth_services.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  String? get currentUserId => _user?.uid;
  AuthProvider(this._authService) {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

