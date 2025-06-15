import 'package:flutter/material.dart';

Widget navItem(IconData outlinedIcon, IconData filledIcon, bool isActive) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(isActive ? filledIcon : outlinedIcon, size: 30),
    ],
  );
}
