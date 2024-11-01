import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _fetchUserData(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<UserCredential> signUp(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await _authService.signUp(email, password);
      if (userCredential.user != null) {
        await _createUserInFirestore(
            userCredential.user!.uid, email, displayName);
      }
      await _setLoggedIn(true);
      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(e.message ?? 'An error occurred during sign up',
            code: e.code);
      }
      throw AuthException('Sign up failed: $e');
    }
  }

  Future<void> _createUserInFirestore(
      String uid, String email, String displayName) async {
    try {
      UserModel newUser =
          UserModel(uid: uid, email: email, displayName: displayName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap());
    } catch (e) {
      throw Exception('Failed to create user in Firestore: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _authService.signIn(email, password);
      await _setLoggedIn(true);
      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(e.message ?? 'An error occurred during sign in',
            code: e.code);
      }
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      notifyListeners();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential?.user != null) {
        await _createOrUpdateGoogleUser(userCredential!.user!);
        await _fetchUserData(userCredential.user!.uid); // Fetch user data
        await _setLoggedIn(true);
      }
      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(
            e.message ?? 'An error occurred during Google sign in',
            code: e.code);
      }
      throw AuthException('Google sign in failed: $e');
    }
  }

  Future<void> _createOrUpdateGoogleUser(User firebaseUser) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update({
          'displayName': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoURL,
        });
      }
    } catch (e) {
      throw Exception('Failed to create/update Google user in Firestore: $e');
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      } else {
        // Handle the case where the user document does not exist
        _user = null;
        notifyListeners();
        throw Exception('User document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> updateUserProfile(
      {String? displayName, String? photoUrl}) async {
    try {
      User? firebaseUser = _authService.getCurrentUser();
      if (firebaseUser != null) {
        if (displayName != null) {
          await firebaseUser.updateDisplayName(displayName);
        }
        if (photoUrl != null) await firebaseUser.updatePhotoURL(photoUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update({
          if (displayName != null) 'displayName': displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });

        _user = _user?.copyWith(displayName: displayName, photoUrl: photoUrl);
        notifyListeners();
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> _setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  bool get isAuthenticated => _user != null;
}
