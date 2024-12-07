import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodpundit/config/environment_config.dart';
import '../models/user_details.dart';
import 'network_service.dart';
import 'product_service.dart';
import 'offline_profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final NetworkService _networkService = NetworkService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final OfflineProfileService _offlineProfileService = OfflineProfileService();
  UserDetails? _currentUserDetails;

  AuthService() {
    // Set Firebase Auth language to English
    _auth.setLanguageCode('en');
    // Initialize user details when auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          await _handleUserDetails(user);
        } catch (e) {
          print('Error handling user details: $e');
          // Fallback to basic user details if Firestore operation fails
          _currentUserDetails = await UserDetails.fromFirebaseUser(user);
        }
      } else {
        _currentUserDetails = null;
      }
    });
  }

  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  // Helper method to check network connection
  Future<void> _checkNetworkConnection() async {
    try {
      if (!await _networkService.checkConnection()) {
        throw 'No internet connection. Please check your network settings and try again.';
      }
    } catch (e) {
      // If we get a MissingPluginException, continue without blocking
      if (!e.toString().contains('MissingPluginException')) {
        throw e.toString();
      }
    }
  }

  // Getter for current user details
  UserDetails? get currentUserDetails => _currentUserDetails;

  // Core function to handle user details in Firestore
  Future<UserDetails?> _handleUserDetails(User user,
      {UserDetails? updatedDetails}) async {
    try {
      final docRef = _firestore
          .collection(EnvironmentConfig.usersCollection)
          .doc(user.uid);

      if (updatedDetails != null) {
        // Update case
        await docRef.set(updatedDetails.toFirestore(), SetOptions(merge: true));
        return updatedDetails;
      }

      // Fetch case
      final doc = await docRef.get();
      if (doc.exists) {
        final existingDetails = UserDetails.fromFirestore(doc);

        // Check if we need to update the photo URL from the provider
        if (user.photoURL != null &&
            user.photoURL != existingDetails.photoURL) {
          final updatedDetails =
              existingDetails.copyWith(photoURL: user.photoURL);
          await docRef.update({'photoURL': user.photoURL});
          return updatedDetails;
        }

        return existingDetails;
      }

      // Create new user case
      final newDetails = UserDetails(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        birthDate: null,
        heightCm: null,
        weightKg: null,
        workoutLevel: WorkoutLevel.none,
        healthConditions: const [],
        allergies: const [],
        isCalorieCounter: false,
        dateJoined: DateTime.now(),
        totalScans: 0,
        preferences: const {},
        phoneNumber: user.phoneNumber,
        product_history: const [],
        favorites: const [],
      );

      await docRef.set(newDetails.toFirestore());
      return newDetails;
    } catch (e) {
      throw 'Failed to handle user details: $e';
    }
  }

  // Public method to fetch user details
  Future<UserDetails?> fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _handleUserDetails(user);
  }

  // Public method to update user details
  Future<void> updateUserDetails(UserDetails updatedDetails) async {
    await _checkNetworkConnection();
    final user = _auth.currentUser;
    if (user == null) throw 'No authenticated user found';
    await _handleUserDetails(user, updatedDetails: updatedDetails);
  }

  // Email & Password Sign Up
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validate email format before making Firebase call
    if (!isValidEmail(email)) {
      throw 'Please enter a valid email address (e.g., user@example.com)';
    }

    await _checkNetworkConnection();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      if (userCredential.user != null) {
        await userCredential.user!.updateProfile(displayName: name);
        // Optional: Send email verification
        await userCredential.user!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _checkNetworkConnection();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Fetch user details after successful sign in
      await fetchUserDetails();
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    await _checkNetworkConnection();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      // Fetch user details after successful sign in
      await fetchUserDetails();
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    await _checkNetworkConnection();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      // Fetch user details after successful sign in
      await fetchUserDetails();
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Anonymous Sign In
  Future<UserCredential> signInAnonymously() async {
    await _checkNetworkConnection();
    try {
      print('DEBUG: Starting anonymous sign in');
      final userCredential = await _auth.signInAnonymously();
      print('DEBUG: Anonymous sign in successful: ${userCredential.user?.uid}');
      // Create basic user details for anonymous user
      if (userCredential.user != null) {
        print('DEBUG: Creating user details for anonymous user');
        final anonymousDetails = UserDetails(
          uid: userCredential.user!.uid,
          email: null,
          displayName: 'User',
          photoURL: null,
          emailVerified: false,
          birthDate: null,
          heightCm: null,
          weightKg: null,
          workoutLevel: WorkoutLevel.none,
          healthConditions: const [],
          allergies: const [],
          isCalorieCounter: false,
          dateJoined: DateTime.now(),
          totalScans: 0,
          preferences: const {},
          phoneNumber: null,
          product_history: const [],
          favorites: const [],
        );
        print('DEBUG: Saving user details to Firestore');
        await _handleUserDetails(userCredential.user!,
            updatedDetails: anonymousDetails);
        print('DEBUG: User details saved successfully');
      }
      return userCredential;
    } catch (e) {
      print('DEBUG: Error in anonymous sign in: $e');
      throw _handleAuthException(e);
    }
  }

  // Convert anonymous account to permanent account
  Future<UserCredential> convertAnonymousAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    await _checkNetworkConnection();
    final currentUser = _auth.currentUser;

    if (currentUser == null || !currentUser.isAnonymous) {
      throw 'No anonymous user signed in';
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await currentUser.linkWithCredential(credential);

      // Update user profile with name
      await userCredential.user?.updateProfile(displayName: name);

      // Update user details in Firestore
      if (userCredential.user != null) {
        final updatedDetails = UserDetails(
          uid: userCredential.user!.uid,
          email: email,
          displayName: name,
          photoURL: null,
          emailVerified: false,
          birthDate: null,
          heightCm: null,
          weightKg: null,
          workoutLevel: WorkoutLevel.none,
          healthConditions: const [],
          allergies: const [],
          isCalorieCounter: false,
          dateJoined: DateTime.now(),
          totalScans: 0,
          preferences: const {},
          phoneNumber: null,
          product_history: const [],
          favorites: const [],
        );
        await _handleUserDetails(userCredential.user!,
            updatedDetails: updatedDetails);
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Get current user before signing out to check provider
      final currentUser = _auth.currentUser;
      final isGoogleUser = currentUser?.providerData
              .any((userInfo) => userInfo.providerId == 'google.com') ??
          false;

      // Clear all offline data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all SharedPreferences data
      await _productService.clearCache(); // Clear product cache
      await _offlineProfileService
          .clearOfflineData(); // Clear offline profile data

      // Sign out from Firebase first
      await _auth.signOut();

      // If user was signed in with Google, sign out from Google as well
      if (isGoogleUser) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          // Ignore Google sign out errors as Firebase sign out is more important
          print('Google sign out failed: $e');
        }
      }

      // Clear user details last
      _currentUserDetails = null;
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!isValidEmail(email)) {
      throw 'Please enter a valid email address (e.g., user@example.com)';
    }

    await _checkNetworkConnection();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'weak-password':
          return 'The password provided is too weak';
        case 'email-already-in-use':
          return 'An account already exists for that email';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'invalid-email':
          return 'The email address is invalid';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials';
        case 'invalid-credential':
          return 'The credential is invalid or has expired';
        case 'network-request-failed':
          return 'Network error. Please check your connection and try again.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          return e.message ?? 'An authentication error occurred';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
