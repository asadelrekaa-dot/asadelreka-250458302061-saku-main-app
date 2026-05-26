import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  static const _clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _firebaseInitialized = false;
  bool _initialized = false;

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseReady();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential);
    } on FirebaseAuthException catch (error) {
      throw GoogleAuthSetupException(_mapAuthMessage(error));
    }
  }

  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseReady();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential);
    } on FirebaseAuthException catch (error) {
      throw GoogleAuthSetupException(_mapAuthMessage(error));
    }
  }

  Future<User> authenticate() async {
    await _ensureFirebaseReady();
    await _initialize();

    try {
      final account = await _authenticateWithGoogle();
      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const GoogleAuthSetupException(
          'Token Google tidak tersedia. Pastikan SHA fingerprint Android sudah '
          'terdaftar di Firebase.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return _requireUser(userCredential);
    } on FirebaseAuthException catch (error) {
      throw GoogleAuthSetupException(_mapAuthMessage(error));
    } on GoogleAuthSetupException {
      rethrow;
    } catch (_) {
      throw const GoogleAuthSetupException(
        'Login Google dibatalkan atau belum berhasil.',
      );
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) return;
    await _ensureFirebaseReady();
    await FirebaseAuth.instance.signOut();
    if (_initialized) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> _ensureFirebaseReady() async {
    if (kIsWeb) {
      throw const GoogleAuthSetupException(
        'Auth web belum dikonfigurasi. Uji login asli lewat build Android.',
      );
    }

    if (_firebaseInitialized) return;
    await Firebase.initializeApp();
    _firebaseInitialized = true;
  }

  Future<GoogleSignInAccount> _authenticateWithGoogle() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthSetupException(
        'Platform ini belum mendukung proses Google Sign-In langsung.',
      );
    }
    return _googleSignIn.authenticate();
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      clientId: _clientId.isEmpty ? null : _clientId,
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _initialized = true;
  }

  User _requireUser(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw const GoogleAuthSetupException(
        'Auth berhasil, tapi data user belum tersedia.',
      );
    }
    return user;
  }

  String _mapAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Format email belum valid.',
      'user-disabled' => 'Akun ini sedang dinonaktifkan.',
      'user-not-found' => 'Akun belum terdaftar.',
      'wrong-password' ||
      'invalid-credential' =>
        'Email atau password belum sesuai.',
      'email-already-in-use' => 'Email ini sudah terdaftar.',
      'weak-password' => 'Password terlalu lemah, minimal 6 karakter.',
      'operation-not-allowed' =>
        'Provider auth belum diaktifkan di Firebase Console.',
      'network-request-failed' => 'Koneksi internet bermasalah.',
      _ => error.message ?? 'Auth belum berhasil. Coba lagi sebentar.',
    };
  }
}

class GoogleAuthSetupException implements Exception {
  const GoogleAuthSetupException(this.message);

  final String message;
}
