import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/helpers/firebase_provider_helper.dart';
import 'package:we_char/models/message_model.dart';
import 'package:we_char/models/user_model.dart';

import 'package:http/http.dart' as http;

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
      firebaseFirestore: ref.watch(firebaseFirestoreProvider),
      firebaseAuth: ref.watch(firebaseAuthProvider),
      firebaseStorage: ref.watch(firebaseStorageProvider),
      firebaseMessaging: ref.watch(firebaseMessageProfiver));
});

class ChatRepository {
  final FirebaseFirestore _firebaseFirestore;

  final FirebaseAuth _firebaseAuth;

  final FirebaseMessaging _firebaseMessaging;

  final FirebaseStorage _firebaseStorage;

  ChatRepository(
      {required FirebaseFirestore firebaseFirestore,
      required FirebaseAuth firebaseAuth,
      required FirebaseStorage firebaseStorage,
      required FirebaseMessaging firebaseMessaging})
      : _firebaseFirestore = firebaseFirestore,
        _firebaseAuth = firebaseAuth,
        _firebaseStorage = firebaseStorage,
        _firebaseMessaging = firebaseMessaging;

  User get user => _firebaseAuth.currentUser!;
  String getConvert(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  Stream<List<MessageModel>> getAllMessage(UserModel user) {
    return _firebaseFirestore
        .collection('chats/${getConvert(user.id.toString())}/messages')
        .snapshots()
        .map((event) {
      List<MessageModel> re = [];

      for (var doc in event.docs) {
        re.add(MessageModel.fromMap(doc.data()));
      }
      return re;
    });
  }

  Future<void> sendMessage(
      UserModel userChat, String message, Type type) async {
    final MessageModel messageModel = MessageModel(
        fromId: user.uid,
        msg: message,
        read: DateTime.utc(2001, 08, 30).toLocal(),
        sent: DateTime.now(),
        toId: userChat.id.toString(),
        type: type);

    final ref = _firebaseFirestore
        .collection('chats/${getConvert(userChat.id.toString())}/messages');

    await ref
        .doc(messageModel.sent.millisecondsSinceEpoch.toString())
        .set(messageModel.toMap())
        .then((value) => sendPushNotification(
            userChat, type == Type.text ? message : 'image', user.uid));
  }

  Future<void> updateMessageReadStatus(MessageModel messageModel) async {
    await _firebaseFirestore
        .collection('chats/${getConvert(messageModel.fromId)}/messages')
        .doc(messageModel.sent.millisecondsSinceEpoch.toString())
        .update(messageModel.copyWith(read: DateTime.now()).toMap());
  }

  Stream<List<MessageModel>> getLastMessage(UserModel userModel) {
    return _firebaseFirestore
        .collection('chats/${getConvert(userModel.id.toString())}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .map((event) {
      List<MessageModel> re = [];
      for (var doc in event.docs) {
        re.add(MessageModel.fromMap(doc.data()));
      }
      return re;
    });
  }

  Future<void> sendChatImage(UserModel userModel, File file) async {
    final ext = file.path.split('.').last;

    TaskSnapshot taskSnapshot = await _firebaseStorage
        .ref()
        .child(
            'images/${getConvert(userModel.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext')
        .putFile(file, SettableMetadata(contentType: 'image/$ext'));

    String image = await taskSnapshot.ref.getDownloadURL();
    await sendMessage(userModel, image, Type.image);
  }

  Stream<List<UserModel>> getUserInfo(UserModel userModel) {
    return _firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: userModel.id)
        .snapshots()
        .map((event) {
      List<UserModel> re = [];
      for (var doc in event.docs) {
        re.add(UserModel.fromMap(doc.data()));
      }
      return re;
    });
  }

  Future<void> updateStatus(bool isOnline) async {
    String token = '';
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.getToken().then((value) {
      if (value != null) {
        token = value;
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
    await _firebaseFirestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now(),
      'pushToken': token
    });
  }

  Future<void> sendPushNotification(
      UserModel userModel, String msg, fromId) async {
    try {
      final body = {
        "to": userModel.pushToken,
        "notification": {
          "title": userModel.name,
          "body": msg,
          "android_channel_id": "wechat"
        },
        "data": {
          "click_action": "User ID : $fromId",
        }
      };
      var response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAASivgsO4:APA91bH-TQdO1qe1vteipGHd9gbwgLhIfMtC__58XbTyteoxPlOLvqJgy7Kkdq8ZFfEEK14YoP2r218www0Wbgabq4QKRc9k4rIPGn1JuJ67_b2guIALwepntfJHKh_oaV-FqBuWklrP'
              },
              body: jsonEncode(body));

      log('status : ${response.statusCode}');
      log('body : ${response.body}');
    } catch (e) {
      log('\nerror : $e');
    }
  }

  Future<void> deleteMessage(MessageModel messageModel) async {
    await _firebaseFirestore
        .collection('chats/${getConvert(messageModel.toId)}/messages')
        .doc(messageModel.sent.millisecondsSinceEpoch.toString())
        .delete();
    if (messageModel.type == Type.image) {
      await _firebaseStorage.refFromURL(messageModel.msg).delete();
    }
  }

  Future<void> updateMessage(MessageModel messageModel,String msg) async {
    await _firebaseFirestore
        .collection('chats/${getConvert(messageModel.toId)}/messages')
        .doc(messageModel.sent.millisecondsSinceEpoch.toString())
        .update({'msg': msg});
   
  }
}
