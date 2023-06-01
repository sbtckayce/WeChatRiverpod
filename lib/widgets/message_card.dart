import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:we_char/features/auth/controller/login_controller.dart';
import 'package:we_char/features/chat/controller/chat_controller.dart';
import 'package:we_char/models/message_model.dart';
import 'package:we_char/widgets/option_item.dart';

class MessageCard extends ConsumerStatefulWidget {
  const MessageCard({super.key, required this.messageModel});
  final MessageModel messageModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageCardState();
}

class _MessageCardState extends ConsumerState<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showBottomSheetOption(context, ref);
      },
      child: ref.watch(loginControllerProvider).user.uid ==
              widget.messageModel.fromId
          ? greenMessage(ref)
          : blueMessage(ref),
    );
  }

  void showDialogUpdate(BuildContext context) {
    String updateMessage = widget.messageModel.msg;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.message_outlined,
                color: Colors.blue,
                size: 25,
              ),
              Text('Update Message'),
            ],
          ),
          content: TextFormField(
            initialValue: updateMessage,
            onChanged: (value) => updateMessage=value,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          actions: [
            MaterialButton(onPressed: () {
              Navigator.pop(context);
            },child: const Text('Cancel',style: TextStyle(color: Colors.blue,fontSize: 16),),),
             MaterialButton(onPressed: () {
              Navigator.pop(context);
              ref.read(chatControllerProvider).updateMessage(widget.messageModel, updateMessage);
            },child: const Text('Update',style: TextStyle(color: Colors.blue,fontSize: 16),),)
          ],
        );
      },
    );
  }

  void showBottomSheetOption(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: MediaQuery.of(context).size.width * 0.35),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.messageModel.type == Type.text
                ? OptionItem(
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: Colors.blueAccent,
                    ),
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.messageModel.msg))
                          .then((value) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Text Copied!')));
                      });
                    },
                    text: 'Copy')
                : OptionItem(
                    icon: const Icon(
                      Icons.download_outlined,
                      color: Colors.blueAccent,
                    ),
                    onTap: () async {
                      try {
                        log('image path : ${widget.messageModel.msg}');
                        GallerySaver.saveImage(widget.messageModel.msg,
                                albumName: 'wechat')
                            .then((value) {
                          Navigator.pop(context);
                          if (value != null && value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Download image !')));
                          }
                        });
                      } catch (e) {
                        log('error: $e');
                      }
                    },
                    text: 'Save Image'),
            const Divider(),
            ref.watch(loginControllerProvider).user.uid ==
                    widget.messageModel.fromId
                ? Column(
                    children: [
                      widget.messageModel.type == Type.text
                          ?  OptionItem(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blueAccent,
                              ),
                              onTap: () {
                                showDialogUpdate(context);
                              },
                              text: 'Edit')
                          : const SizedBox(),
                      OptionItem(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onTap: () {
                            ref
                                .read(chatControllerProvider)
                                .deleteMessage(widget.messageModel)
                                .then((value) {
                              Navigator.pop(context);
                            });
                          },
                          text: 'Delete')
                    ],
                  )
                : const SizedBox(),
            const Divider(),
            OptionItem(
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.blueAccent,
                ),
                text:
                    'Send At : ${DateFormat.jm().format(widget.messageModel.sent).toString()}'),
            OptionItem(
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.greenAccent,
                ),
                text: (widget.messageModel.read !=
                        DateTime.utc(2001, 08, 30).toLocal())
                    ? 'Read At : ${DateFormat.jm().format(widget.messageModel.read).toString()}'
                    : 'Not seen yet')
          ],
        );
      },
    );
  }

  Widget greenMessage(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (widget.messageModel.read !=
                DateTime.utc(2001, 08, 30).toLocal())
              const Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 10,
            ),
            Text(DateFormat.jm().format(widget.messageModel.sent).toString(),
                style: const TextStyle(fontSize: 13, color: Colors.black87))
          ],
        ),
        widget.messageModel.type == Type.text
            ? Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightGreen),
                    color: const Color.fromARGB(255, 218, 255, 276),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30)),
                  ),
                  child: Text(
                    widget.messageModel.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              )
            : Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.lightGreen),
                  color: const Color.fromARGB(255, 218, 255, 276),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.messageModel.msg,
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
      ],
    );
  }

  Widget blueMessage(WidgetRef ref) {
    if (widget.messageModel.read == DateTime.utc(2001, 08, 30).toLocal()) {
      ref
          .read(chatControllerProvider)
          .updateMessageReadStatus(widget.messageModel);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.messageModel.type == Type.text
              ? Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      color: const Color.fromARGB(255, 221, 245, 255),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    ),
                    child: Text(
                      widget.messageModel.msg,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                )
              : Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.lightBlue),
                    color: const Color.fromARGB(255, 221, 245, 255),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.messageModel.msg,
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
                  )),
          Row(
            children: [
              if (widget.messageModel.read !=
                  DateTime.utc(2001, 08, 30).toLocal())
                const Icon(
                  Icons.done_all_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              const SizedBox(
                width: 10,
              ),
              Text(
                DateFormat.jm().format(widget.messageModel.sent).toString(),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          )
        ],
      ),
    );
  }
}
