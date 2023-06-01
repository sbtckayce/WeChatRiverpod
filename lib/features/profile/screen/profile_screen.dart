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
import '../../chat/controller/chat_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.userModel});
  final UserModel userModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final aboutController = TextEditingController();
  String? image;

  @override
  void initState() {
    nameController.text = widget.userModel.name;
    aboutController.text = widget.userModel.about;
    super.initState();
  }

  void showBottomSheetCamera() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: const Size(100, 100)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? imageFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (imageFile != null) {
                        log('Image Path : ${imageFile.path} -- MimeType : ${imageFile.mimeType}');
                        setState(() {
                          image = imageFile.path;
                        });
                        if (!mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/add_image.png')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: const Size(100, 100)),
                    onPressed: ()async {
                      ImagePicker picker = ImagePicker();
                      final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);
                      if(imageFile!=null){
                          log('Image Path : ${imageFile.path} -- MimeType : ${imageFile.mimeType}');
                        setState(() {
                          image =imageFile.path;
                        });
                          if (!mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/camera.png'))
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => showBottomSheetCamera(),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
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
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_4_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      TextFormField(
                        controller: aboutController,
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: Size(mq.width * 0.5, mq.height * 0.06)),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        UserModel userModelNew = UserModel(
                            id: widget.userModel.id,
                            name: nameController.text,
                            email: widget.userModel.email,
                            image: widget.userModel.image,
                            isOnline: widget.userModel.isOnline,
                            createAt: widget.userModel.createAt,
                            lastActive: widget.userModel.lastActive,
                            about: aboutController.text,
                            pushToken: widget.userModel.pushToken);
                        ref
                            .read(profileControllerProvider)
                            .updateProfilePicture(userModel: userModelNew, image: File(image!))
                            .then((value) {
                          Navigator.pop(context);
                          ref.invalidate(getCurrenUserInfoProvider);
                        });
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update'))
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () {
               ref.read(loginControllerProvider).signOut();
                ref.read(chatControllerProvider).updateStatus(false);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>const LoginScreen(),));
            },
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Logout'),
          ),
        ),
      ),
    );
  }
}
