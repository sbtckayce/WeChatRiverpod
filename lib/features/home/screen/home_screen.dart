import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/auth/controller/login_controller.dart';
import 'package:we_char/features/auth/screen/login_screen.dart';
import 'package:we_char/features/chat/controller/chat_controller.dart';
import 'package:we_char/features/home/controller/home_controller.dart';
import 'package:we_char/features/profile/screen/profile_screen.dart';
import 'package:we_char/features/splash/screen/splash_screen.dart';
import 'package:we_char/models/user_model.dart';
import 'package:we_char/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late UserModel userModel;
  bool isSearch = false;
  
  String text ="";
  TextEditingController searchController = TextEditingController();
    TextEditingController addUserController = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      ref.read(chatControllerProvider).updateStatus(true);
    },);
    super.initState();
   
  }
    @override
  void dispose() {
     Future.delayed(Duration.zero,() {
      ref.read(chatControllerProvider).updateStatus(false);
    },);
    super.dispose();
  }


  void showDialogAdd(BuildContext context) {
  
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
                Icons.person_add_alt_1_outlined,
                color: Colors.blue,
                size: 25,
              ),
              Text('Add User'),
            ],
          ),
          content: TextFormField(
            
            controller: addUserController,
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
             ref.read(homeControllerProvider).addUserModel(addUserController.text).then((value) {
              if(!value){
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User does not exist')));
              }
             });
            },child: const Text('Add',style: TextStyle(color: Colors.blue,fontSize: 16),),)
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
          leading: const Icon(Icons.home),
          title: isSearch
              ?TextField(
                controller: searchController,
                  decoration:const InputDecoration(
                    
                      border: InputBorder.none, hintText: 'Name,Email,...'),
                      onChanged: (value) {
                        
                       setState(() {
                         text = searchController.text;
                       });
                      
                      },
                )
              : const Text('We chat'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isSearch = !isSearch;
                    text="";
                    searchController.clear();
                  });
                },
                icon: Icon(isSearch ? Icons.close : Icons.search)),
            ref.watch(getCurrenUserInfoProvider).when(
                  data: (userModel) {
                    return IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(userModel: userModel),
                              ));
                        },
                        icon: const Icon(Icons.more_vert));
                  },
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator(),
                )
          ],
        ),
        body: ref.watch(getAllUserModelProvider(text)).when(
            data: (data) {
              if(data.isNotEmpty){
                return ListView.builder(
                padding: EdgeInsets.only(top: mq.height * 0.02),
                itemCount: data.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ChatUserCard(
                    userModel: data[index],
                  );
                },
              );
              }else{
                return const Text('No User');
              }
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator()),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
              onPressed: () {
              showDialogAdd(context);
              },
              child: const Icon(Icons.add_comment_rounded)),
        ),
      ),
    );
  }
}
