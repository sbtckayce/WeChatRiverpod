import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:we_char/features/chat/controller/chat_controller.dart';
import 'package:we_char/features/chat/screen/chat_screen.dart';
import 'package:we_char/models/message_model.dart';
import 'package:we_char/models/user_model.dart';
import 'package:we_char/widgets/profile_dialog.dart';

class ChatUserCard extends ConsumerWidget {
  const ChatUserCard({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(userModel: userModel),
              ));
        },
        child: ref.watch(getLastMessageProvider(userModel)).when(
              data: (messages) {
                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: mq.width * 0.05, vertical: 5),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(context: context, builder: (context) => ProfileDialog(userModel:userModel),);
                      },
                      child: CircleAvatar(
                          child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: userModel.image,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )),
                    ),
                    title: Text(userModel.name),
                    subtitle: Text(
                      messages.isNotEmpty
                          ? messages.first.type == Type.text
                              ? messages.first.msg
                              : 'image'
                          : userModel.about,
                      maxLines: 1,
                    ),
                    trailing: Text(
                      messages.isNotEmpty
                          ? DateFormat.jm()
                              .format(messages.first.sent)
                              .toString()
                          : userModel.createAt.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ));
  }
}
