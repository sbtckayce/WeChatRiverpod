import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:we_char/features/chat/controller/chat_controller.dart';
import 'package:we_char/features/view_profile/screen/view_profile_screen.dart';
import 'package:we_char/models/message_model.dart';
import 'package:we_char/models/user_model.dart';
import 'package:we_char/widgets/message_card.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.userModel});
  final UserModel userModel;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  bool showEmoji = false;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 248, 255),
        appBar: AppBar(
            toolbarHeight: 60,
            title: ref.watch(getUserInfoProvider(widget.userModel)).when(
                data: (data) {
                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewProfileScreen(userModel: widget.userModel),
                        )),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: CircleAvatar(
                              child: Image.network(
                            data.isNotEmpty
                                ? data.first.image
                                : widget.userModel.image,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.isNotEmpty
                                  ? data.first.name
                                  : widget.userModel.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              data.first.isOnline
                                  ? 'Online'
                                  : 'Last seen to day at ${DateFormat.jm().format(data.first.lastActive).toString()}',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ))),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Expanded(
                  child: ref
                      .watch(getAllMessageProvider(widget.userModel))
                      .when(
                        data: (messages) {
                          return ListView.builder(
                            itemCount: messages.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(messageModel: messages[index]);
                            },
                          );
                        },
                        error: (error, stackTrace) => Text(error.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )),
              showLoading
                  ? const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const SizedBox(),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  showEmoji = !showEmoji;
                                });
                              },
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.blueAccent,
                              )),
                          Expanded(
                              child: TextField(
                            keyboardType: TextInputType.multiline,
                            controller: messageController,
                            decoration: const InputDecoration(
                                hintText: 'Type Something...',
                                hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                                ),
                                border: InputBorder.none),
                          )),
                          IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile?> images =
                                    await picker.pickMultiImage();
                                for (var i in images) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                  ref
                                      .read(chatControllerProvider)
                                      .sendChatImage(
                                          widget.userModel, File(i!.path));
                                  setState(() {
                                    showLoading = false;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.image_outlined,
                                color: Colors.blueAccent,
                              )),
                          IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera);
                                if (image != null) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                  ref
                                      .read(chatControllerProvider)
                                      .sendChatImage(
                                          widget.userModel, File(image.path));
                                  setState(() {
                                    showLoading = false;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.blueAccent,
                              ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        ref.read(chatControllerProvider).sendMessage(
                            widget.userModel,
                            messageController.text,
                            Type.text);

                        messageController.text = '';
                        FocusScope.of(context).unfocus();
                        // setState(() {
                        //   showEmoji = !showEmoji;
                        // });
                      }
                    },
                    padding: const EdgeInsets.all(10),
                    minWidth: 0,
                    shape: const CircleBorder(),
                    color: Colors.green,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                ],
              ),
              showEmoji
                  ? SizedBox(
                      height: 200,
                      child: EmojiPicker(
                        textEditingController:
                            messageController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: Config(
                          bgColor: const Color.fromARGB(255, 234, 248, 255),
                          columns: 7,
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.30
                                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
