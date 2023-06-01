import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_char/helpers/firebase_provider_helper.dart';
import 'package:we_char/helpers/dialog_helper.dart';
import 'package:we_char/models/user_model.dart';

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepository(
      firebaseAuth: ref.watch(firebaseAuthProvider),
      googleSignIn: ref.watch(googleSignInProvider),
      firebaseFirestore: ref.watch(firebaseFirestoreProvider));
});

class LoginRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firebaseFirestore;
  LoginRepository(
      {required FirebaseAuth firebaseAuth,
      required GoogleSignIn googleSignIn,
      required FirebaseFirestore firebaseFirestore})
      : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firebaseFirestore = firebaseFirestore;

  Stream<User?> get getAuthStateChange => _firebaseAuth.authStateChanges();
  CollectionReference get users => _firebaseFirestore.collection('users');
  User get user => _firebaseAuth.currentUser!;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
// Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      log('\nSignInWithGoogle : $e');

      return null;
    }
  }

  signOut() async {
    await _firebaseAuth.signOut();
     await _googleSignIn.signOut();
   
  }

  Future<bool> userExists() async {
    return (await users.doc(user.uid).get()).exists;
  }

  Future<void> createUser() async {
    final time = DateTime.now();
    UserModel userModel = UserModel(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        image: user.photoURL.toString(),
        isOnline: false,
        createAt: time,
        lastActive: time,
        about: 'I\'m using We Chat !',
        pushToken: '');

        return await users.doc(user.uid).set(userModel.toMap());
  }
}
