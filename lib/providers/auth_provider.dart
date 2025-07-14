import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? newUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: newUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'AuthState(user: ${user?.email}, isLoading: $isLoading, error: $error)';
}

class AuthNotifier extends StateNotifier<AuthState> {
  late final StreamSubscription<User?> _authStateSubscription;

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    debugPrint('🔐 AuthNotifier initialized');
    _initAuthListener();
  }

  void _initAuthListener() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        debugPrint('🔐 Auth state changed: ${user?.email ?? 'No user'} (UID: ${user?.uid})');
        state = state.copyWith(newUser: user, isLoading: false, error: null);
        debugPrint('🔐 New state: $state');
      },
      onError: (error) {
        debugPrint('🔐 Auth listener error: $error');
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  @override
  void dispose() {
    debugPrint('🔐 AuthNotifier disposed');
    _authStateSubscription.cancel();
    super.dispose();
  }

  // Sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('🔐 Attempting sign in: $email');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 Sign in successful');
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      debugPrint('🔐 Sign in error: ${e.code} - $errorMessage');
      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      debugPrint('🔐 Unexpected sign in error: $e');
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  // Sign up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    debugPrint('🔐 Attempting sign up: $email');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 Sign up successful');
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getErrorMessage(e.code);
      debugPrint('🔐 Sign up error: ${e.code} - $errorMessage');
      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      debugPrint('🔐 Unexpected sign up error: $e');
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    debugPrint('🔐 Attempting sign out');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('🔐 Sign out successful');
    } catch (e) {
      debugPrint('🔐 Sign out error: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to sign out');
    }
  }

  void clearError() {
    if (state.error != null) {
      debugPrint('🔐 Clearing error: ${state.error}');
      state = state.copyWith(error: null);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});