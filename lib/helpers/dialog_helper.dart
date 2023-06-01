import 'package:flutter/material.dart';

class DialogHelper{
  static void showSnackBar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg),backgroundColor: Colors.blueAccent,behavior: SnackBarBehavior.floating,));
  }
  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (context) =>const Center(child:  CircularProgressIndicator(color: Colors.blueAccent,)),);
  }
}