import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:music_diary_new/core/models/user_profile.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ValueNotifier<UserProfile?> authState =
      ValueNotifier<UserProfile?>(null);

  StreamSubscription<User?>? _authSubscription;
  UserProfile? _currentUser;

  UserProfile? get currentProfile => _currentUser;
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> initialize() async {
    await _authSubscription?.cancel();
    _authSubscription = _firebaseAuth.userChanges().listen(_handleUserChanged);
    _handleUserChanged(_firebaseAuth.currentUser);
  }

  void _handleUserChanged(User? user) {
    _currentUser =
        user == null ? null : UserProfile.fromFirebaseUser(user);
    authState.value = _currentUser;
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } catch (_) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } catch (_) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    await user.updateDisplayName(displayName);
    await user.reload();
    _handleUserChanged(_firebaseAuth.currentUser);
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-mismatch':
      case 'missing-password':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Weak password';
      case 'user-not-found':
        return 'User not found';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
  }
}
