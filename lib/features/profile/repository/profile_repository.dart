import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/helpers/firebase_provider_helper.dart';
import 'package:we_char/models/user_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
      firebaseStorage: ref.watch(firebaseStorageProvider),
      firebaseAuth: ref.watch(firebaseAuthProvider),
      firebaseFirestore: ref.watch(firebaseFirestoreProvider));
});

class ProfileRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  ProfileRepository(
      {required FirebaseStorage firebaseStorage,
      required FirebaseAuth firebaseAuth,
      required FirebaseFirestore firebaseFirestore})
      : _firebaseStorage = firebaseStorage,
        _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore;

  Future<void> updateProfilePicture(
      {required UserModel userModel, required File image}) async {
    final ext = image.path.split('.').last;
    log('ext : $ext');

    String userId = _firebaseAuth.currentUser!.uid;

    TaskSnapshot taskSnapshot = await _firebaseStorage
        .ref()
        .child('images/$userId.$ext')
        .putFile(image, SettableMetadata(contentType: 'image/$ext'));
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    UserModel userModelNew = userModel.copyWith(image: imageUrl);
    await _firebaseFirestore
        .collection('users')
        .doc(userModelNew.id)
        .set(userModelNew.toMap());
  }
}
