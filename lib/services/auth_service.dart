import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wargo/services/user_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _userService = UserService();
  bool _isCreatingUser = false;

  String? _role;
  String? get role => _role;

  User? get currentUser => _auth.currentUser;

  String? _currentLocation;
  String? get currentLocation => _currentLocation;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    // Panggil fetchRole saat auth state berubah
    _auth.authStateChanges().listen((User? user) async {
      if (!_isCreatingUser) {
        await _fetchRole();
      }
    });
  }

  Future<void> _fetchRole() async {
    if (currentUser != null) {
      _role = await _userService.getRole(currentUser!.uid);
    } else {
      _role = null;
    }
    notifyListeners();
  }

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _isCreatingUser = true;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);
      // await result.user?.updatePhotoURL('');
      await result.user?.reload();

      // Create user document
      try {
        await _userService.createUser(
          uid: result.user!.uid,
          name: name,
          email: email,
          role: role,
        );
      } catch (e) {
        return 'error$e';
      }

      //Set role
      await _fetchRole();

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
    } finally {
      _isCreatingUser = false;
    }
  }

  // Sign In
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      //Set role
      await _fetchRole();

      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-credential':
          return 'Email atau password tidak valid';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Terjadi kesalahan: ${e.code}';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }

  Future<String?> signInWithGoogle({String role = 'user'}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign in cancelled';
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      final userCredential = await _auth.signInWithCredential(credential);
      try {
        await _userService.createUser(
          uid: userCredential.user!.uid,
          name: googleUser.displayName ?? '',
          email: googleUser.email,
          photoUrl: googleUser.photoUrl ?? '',
          role: role,
        );
      } catch (e) {
        return 'error $e';
      }

      await _fetchRole();

      notifyListeners();

      return null; // Success
    } catch (e) {
      return 'Google sign in failed: ${e.toString()}';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    await _fetchRole();
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
