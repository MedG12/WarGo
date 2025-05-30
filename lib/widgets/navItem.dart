import 'package:flutter/material.dart';

Widget navItem(IconData outlinedIcon, IconData filledIcon, bool isActive) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (isActive)
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          height: 2,
          width: 40,
          color: Color(0xFF0E2148),
        ),
      Icon(isActive ? filledIcon : outlinedIcon, size: 30),
    ],
  );
}
