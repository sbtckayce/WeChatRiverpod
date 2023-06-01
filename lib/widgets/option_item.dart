import 'package:flutter/material.dart';

class OptionItem extends StatelessWidget {
  const OptionItem({super.key,required this.icon,required this.text, this.onTap});
  final Widget icon;
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),child: InkWell(
      onTap:  onTap,
      child: Row(children: [
        icon,
        const SizedBox(width: 10,),
        Text(text,style: const TextStyle(fontSize:15,color: Colors.black54 ),)
      ],),
    ),);
  }
}