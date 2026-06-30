import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> saveUserRole(String uid, String role);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> loginWithEmailPassword(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('Autentikasi gagal');
      }
      return await _getUserFromFirestore(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Email atau kata sandi tidak valid');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailPassword(String name, String email, String password) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('Registrasi gagal');
      }
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: 'pending',
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc(userModel.uid).set(userModel.toFirestore());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Gagal membuat akun');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      throw AuthException(
          'Login dengan Google tidak didukung di aplikasi Desktop Windows/Linux. Silakan gunakan Login dengan Email & Kata Sandi atau jalankan di Android / Web.');
    }
    try {
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Login Google dibatalkan pengguna');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw AuthException('Token otentikasi Google tidak ditemukan');
      }
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw AuthException('Autentikasi Google gagal');
      }

      final doc = await firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        final newUserModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'Pengguna Google',
          role: 'both',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await firestore.collection('users').doc(newUserModel.uid).set(newUserModel.toFirestore());
        return newUserModel;
      } else {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Autentikasi Google gagal');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('MissingPluginException') || errStr.contains('UnsupportedError')) {
        throw AuthException(
            'Login dengan Google tidak didukung pada perangkat desktop ini. Silakan gunakan Login Email atau jalankan di Android / Web.');
      }
      if (errStr.contains('10:') || errStr.contains('ApiException: 10') || errStr.contains('sign_in_failed')) {
        throw AuthException(
            'Gagal Login Google (Kode 10: SHA-1 / Konfigurasi Client ID). Pastikan aplikasi di-build untuk Android yang terdaftar di Firebase Console.');
      }
      throw AuthException('Gagal login dengan Google: $errStr');
    }
  }

  @override
  Future<UserModel> saveUserRole(String uid, String role) async {
    try {
      await firestore.collection('users').doc(uid).set({
        'role': role,
      }, SetOptions(merge: true));

      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } else {
        throw ServerException('Dokumen pengguna tidak ditemukan setelah simpan peran');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      return await _getUserFromFirestore(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  Future<UserModel> _getUserFromFirestore(User firebaseUser) async {
    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    } else {
      final fallbackUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Pengguna',
        role: 'pending',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      await firestore.collection('users').doc(firebaseUser.uid).set(fallbackUser.toFirestore());
      return fallbackUser;
    }
  }
}
