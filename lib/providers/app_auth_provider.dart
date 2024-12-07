import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/network_service.dart';
import '../models/user_details.dart';
import '../screens/home/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A provider class that manages authentication state and user details.
///
/// This class handles user authentication, caching of user details, and provides
/// methods for sign in, sign out, and user detail management.
class AppAuthProvider extends ChangeNotifier {
  // ====== Services & Dependencies ======
  final AuthService _authService = AuthService();
  final NetworkService _networkService = NetworkService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ====== State Variables ======
  UserDetails? _userDetails;
  User? _user;
  String? _error;
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  // ====== Constants ======
  static const String _userDetailsKey = 'user_details';
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // ====== Getters ======
  User? get user => _user;
  UserDetails? get userDetails => _userDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get _shouldRefreshCache {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheExpiry;
  }

  // ====== Constructor & Initialization ======
  AppAuthProvider() {
    print('DEBUG: Initializing AppAuthProvider');
    _loadCachedUserDetails();
    _initializeAuthStateListener();
  }

  void _initializeAuthStateListener() {
    _auth.authStateChanges().listen((User? user) async {
      print('DEBUG: Auth state changed - User: ${user?.email}');
      _user = user;
      setLoading(true);
      if (user != null) {
        try {
          print('DEBUG: Creating UserDetails for authenticated user');
          _userDetails = await UserDetails.fromFirebaseUser(user);
          print('DEBUG: UserDetails created successfully ${_userDetails!.uid}');
          notifyListeners();
        } catch (e) {
          print('DEBUG: Error creating UserDetails: $e');
          _userDetails = null;
        }
      } else {
        print('DEBUG: User is null, clearing UserDetails');
        _userDetails = null;
        await _clearCache();
      }
      notifyListeners();
      setLoading(false);
    });
  }

  // ====== State Management Methods ======
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // ====== Cache Management Methods ======
  Future<void> _loadCachedUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDetailsJson = prefs.getString(_userDetailsKey);
      final lastFetchTimeMillis = prefs.getInt('last_fetch_time');

      if (lastFetchTimeMillis != null) {
        _lastFetchTime =
            DateTime.fromMillisecondsSinceEpoch(lastFetchTimeMillis);
      }

      if (userDetailsJson != null) {
        _userDetails = UserDetails.fromJson(userDetailsJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached user details: $e');
    }
  }

  Future<void> _saveUserDetailsToCache(UserDetails details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDetailsKey, details.toJson());
      _lastFetchTime = DateTime.now();
      await prefs.setInt(
          'last_fetch_time', _lastFetchTime!.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving user details to cache: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDetailsKey);
      await prefs.remove('last_fetch_time');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  // ====== Authentication Methods ======
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      setError(null);

      if (!await _networkService.checkConnection()) {
        throw 'No internet connection. Please check your network settings and try again.';
      }

      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e.code);
      setError(errorMessage);
      rethrow;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      setLoading(true);
      setError(null);

      if (!await _networkService.checkConnection()) {
        throw 'No internet connection. Please check your network settings and try again.';
      }

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e.code);
      setError(errorMessage);
      rethrow;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signInWithGoogleNew() async {
    try {
      print('DEBUG: AppAuthProvider - Starting Google sign in');
      setLoading(true);
      setError(null);

      if (!await _networkService.checkConnection()) {
        throw 'No internet connection. Please check your network settings and try again.';
      }

      await _authService.signInWithGoogle();
    } catch (e) {
      print('DEBUG: AppAuthProvider - Error in Google sign in: $e');
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    try {
      setLoading(true);
      setError(null);

      if (!await _networkService.checkConnection()) {
        throw 'No internet connection. Please check your network settings and try again.';
      }

      await _authService.signInWithApple();
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'network-request-failed'
          ? 'Network connection lost. Please check your internet and try again'
          : 'Apple sign in failed';
      setError(errorMessage);
      rethrow;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      print('DEBUG: AppAuthProvider - Starting anonymous sign in');
      setLoading(true);
      setError(null);
      final userCredential = await _authService.signInAnonymously();
      print(
          'DEBUG: AppAuthProvider - Anonymous sign in successful: ${userCredential.user?.uid}');
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      print('DEBUG: AppAuthProvider - Error in anonymous sign in: $e');
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      print('DEBUG: AppAuthProvider - Starting sign out');
      setLoading(true);
      setError(null);

      _userDetails = null;
      _user = null;
      await _clearCache();
      await _authService.signOut();

      print('DEBUG: AppAuthProvider - Successfully signed out');
      notifyListeners();
    } catch (e) {
      print('DEBUG: AppAuthProvider - Error during sign out: $e');
      setError('An error occurred during sign out. Please try again.');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ====== User Details Management ======
  Future<void> updateUserDetails(UserDetails updatedDetails) async {
    try {
      setLoading(true);
      setError(null);

      await _authService.updateUserDetails(updatedDetails);
      _userDetails = updatedDetails;
      await _saveUserDetailsToCache(updatedDetails);

      notifyListeners();
    } catch (e) {
      setError('Failed to update user details: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<UserDetails?> fetchUserDetails() async {
    if (_userDetails != null && !_shouldRefreshCache) {
      return _userDetails;
    }

    try {
      final userDetails = await _authService.fetchUserDetails();
      if (userDetails != null) {
        _userDetails = userDetails;
        await _saveUserDetailsToCache(userDetails);
        notifyListeners();
      }
      return userDetails;
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return _userDetails; // Return cached data if fetch fails
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      setLoading(true);
      setError(null);
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      setError('Failed to send password reset email: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ====== Helper Methods ======
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'network-request-failed':
        return 'Network connection lost. Please check your internet and try again';
      default:
        return 'Authentication failed';
    }
  }
}
