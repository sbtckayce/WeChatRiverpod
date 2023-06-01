import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/home/controller/home_controller.dart';
import 'package:we_char/features/profile/controller/profile_controller.dart';
import 'package:we_char/models/user_model.dart';

import '../../auth/controller/login_controller.dart';
import '../../auth/screen/login_screen.dart';

class ViewProfileScreen extends ConsumerStatefulWidget {
  const ViewProfileScreen({super.key, required this.userModel});
  final UserModel userModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProfileScreenState();
}

class _ViewProfileScreenState extends ConsumerState<ViewProfileScreen> {
  final formKey = GlobalKey<FormState>();

  String? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.userModel.name),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.05,
                ),
                Stack(
                  children: [
                    image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(mq.height * 0.1),
                            child: Image.file(
                              File(image!),
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(mq.height * 0.1),
                            child: Image.network(
                              widget.userModel.image,
                              width: mq.height * 0.2,
                              height: mq.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Text(
                  widget.userModel.email,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(
                  height: mq.height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      widget.userModel.about,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Join on : ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Text(
              widget.userModel.createAt.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
