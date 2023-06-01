import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/chat/repository/chat_repository.dart';
import 'package:we_char/models/message_model.dart';

import '../../../models/user_model.dart';

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(chatRepository: ref.watch(chatRepositoryProvider));
});
final getAllMessageProvider =
    StreamProvider.family<List<MessageModel>, UserModel>((ref, user) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getAllMessage(user);
});

final getLastMessageProvider =
    StreamProvider.family<List<MessageModel>, UserModel>((ref, user) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getLastMessage(user);
});

final getUserInfoProvider =
    StreamProvider.family<List<UserModel>, UserModel>((ref, user) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getUserInfo(user);
});

class ChatController {
  final ChatRepository _chatRepository;

  ChatController({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  Stream<List<MessageModel>> getAllMessage(UserModel user) {
    return _chatRepository.getAllMessage(user);
  }

  Future<void> sendMessage(UserModel userChat, String message, Type type) {
    return _chatRepository.sendMessage(userChat, message, type);
  }

  Future<void> updateMessageReadStatus(MessageModel messageModel) async {
    return _chatRepository.updateMessageReadStatus(messageModel);
  }

  Stream<List<MessageModel>> getLastMessage(UserModel userModel) {
    return _chatRepository.getLastMessage(userModel);
  }

  Future<void> sendChatImage(UserModel userModel, File file) async {
    return _chatRepository.sendChatImage(userModel, file);
  }
   Stream<List<UserModel>> getUserInfo(UserModel userModel){
    return _chatRepository.getUserInfo(userModel);
   }
   Future<void> updateStatus(bool isOnline){
    return _chatRepository.updateStatus(isOnline);
   }
   Future<void> deleteMessage(MessageModel messageModel){
    return _chatRepository.deleteMessage(messageModel);
   }
   Future<void> updateMessage(MessageModel messageModel,String msg){
    return _chatRepository.updateMessage(messageModel, msg);
   }
}
