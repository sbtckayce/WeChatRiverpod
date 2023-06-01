import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/auth/controller/login_controller.dart';
import 'package:we_char/features/home/screen/home_screen.dart';
import 'package:we_char/helpers/dialog_helper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
  
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              width: mq.width * 0.5,
              top: mq.height * 0.15,
              right: isAnimate ? mq.width * 0.25 : -mq.width * 0.25,
              duration: const Duration(seconds: 1),
              child: Image.asset('assets/icons/icon_launcher.png')),
          Positioned(
              bottom: mq.height * 0.15,
              width: mq.width * 0.9,
              left: mq.width * 0.05,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                  onPressed: () {
                    DialogHelper.showProgressBar(context);
                    ref
                        .read(loginControllerProvider)
                        .signInWithGoogle()
                        .then((user) async {
                      Navigator.pop(context);
                      if (user != null) {
                        log('\nUser : ${user.user}');
                        log('\nUserInfo : ${user.additionalUserInfo}');
                        await ref.read(loginControllerProvider).userExists()
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ))
                            : await ref
                                .read(loginControllerProvider)
                                .createUser()
                                .then((value) => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    )));
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: mq.height * 0.05,
                  ),
                  label: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                        TextSpan(text: 'Sign in with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500))
                      ]))))
        ],
      ),
    );
  }
}
