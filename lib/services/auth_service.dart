import 'package:firebase_auth/firebase_auth.dart';
import '../core/error/app_exception.dart';

import 'firebase_service.dart';

class AuthService {
  FirebaseAuth? get _auth => FirebaseService.isAvailable ? FirebaseAuth.instance : null;

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? Stream.value(null);
  User? get currentUser => _auth?.currentUser;
  
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  Future<void> signInAsGuest() async {
    _isGuest = true;
    // Notify listeners or handle guest state globally if needed
    // For now, we just bypass the auth wrapper by returning a success-like state if the UI allows
  }

  Future<UserCredential> signInAnonymously() async {
    if (_auth == null) {
      await signInAsGuest();
      throw AppException(message: 'Firebase unavailable. Guest mode activated.');
    }
    try {
      return await _auth!.signInAnonymously();
    } catch (e) {
      throw AppException(message: 'Anonim giriş yapılamadı: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    if (_auth == null) throw AppException(message: 'Firebase unavailable. Use Guest Mode.');
    try {
      return await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw AppException(message: 'Giriş başarısız: $e');
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    if (_auth == null) throw AppException(message: 'Firebase unavailable. Use Guest Mode.');
    try {
      return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw AppException(message: 'Kayıt başarısız: $e');
    }
  }

  Future<void> signOut() async {
    _isGuest = false;
    if (_auth != null) {
      await _auth!.signOut();
    }
  }
}
