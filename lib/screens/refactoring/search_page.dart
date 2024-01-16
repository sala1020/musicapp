import 'package:flutter/material.dart';

Widget circleAvatar({required double circleradius,required double iconsize}) {
  return  CircleAvatar(
    backgroundColor: const Color.fromARGB(157, 255, 255, 255),
    radius: circleradius,
    child: Icon(
      Icons.mic_outlined,
      size: iconsize,
   
    ),
  );
}
