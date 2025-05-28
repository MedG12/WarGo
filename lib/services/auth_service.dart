import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'invalid-email':
          return 'Format email tidak valid';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }

  // Sign In
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }

  // Google Sign In - METHOD INI HARUS DI DALAM CLASS!
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign in cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Google sign in failed: ${e.toString()}';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google too
    await _auth.signOut();
    notifyListeners();
  }

  // Reset Password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak ditemukan';
        case 'invalid-email':
          return 'Format email tidak valid';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }
}