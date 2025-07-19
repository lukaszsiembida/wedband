import 'package:flutter/material.dart';

class IconWithText extends StatelessWidget {
  final String text;

  IconWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.square_outlined,
          size: 40.0,
          color: Colors.black,
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
