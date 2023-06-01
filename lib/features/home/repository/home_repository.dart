import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/helpers/firebase_provider_helper.dart';
import 'package:we_char/models/user_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
      firebaseFirestore: ref.watch(firebaseFirestoreProvider),
      firebaseAuth: ref.watch(firebaseAuthProvider));
});

class HomeRepository {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth;
 
  HomeRepository(
      {required FirebaseFirestore firebaseFirestore,
      required FirebaseAuth firebaseAuth,
     })
      : _firebaseFirestore = firebaseFirestore,
        _firebaseAuth = firebaseAuth
       ;

  CollectionReference get _users => _firebaseFirestore.collection('users');
  User get user => _firebaseAuth.currentUser!;
  Stream<List<UserModel>> getAllUserModel(String text) {
    return _users.where('id', isNotEqualTo: user.uid).snapshots().map(
      (event) {
        List<UserModel> userList = [];
        for (var doc in event.docs) {
          userList.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        if (text == "") {
          return userList;
        } else {
          return userList
              .where((element) =>
                  element.name.toLowerCase().contains(text.toUpperCase()) ||
                  element.email.toLowerCase().contains(text.toLowerCase()))
              .toList();
        }
      },
    );
  }

  Stream<UserModel> getCurrentUserInfo() {
    return _users.doc(user.uid).get().asStream().map((user) {
      if (user.exists) {
        log('current user: ${user.data()}');
        return UserModel.fromMap(user.data() as Map<String, dynamic>);
      } else {
        return UserModel(
            name: '',
            email: '',
            image: '',
            isOnline: false,
            createAt: DateTime.now(),
            lastActive: DateTime.now(),
            about: '',
            pushToken: '');
      }
    });
  }

  Future<void> updateUserInfo(UserModel userModel) async {
    await _users.doc(userModel.id).update(userModel.toMap());
  }
  Future<bool> addUserModel(String email)async{
    final data = await _firebaseFirestore.collection('users').where('email',isEqualTo: email).get();
    if(data.docs.isNotEmpty && data.docs.first.id !=user.uid){
      _firebaseFirestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id);
      return true;
    }else{
      return false;
    }
  
  }
}
