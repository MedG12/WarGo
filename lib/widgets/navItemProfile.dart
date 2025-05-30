import 'package:flutter/material.dart';

Widget navItemProfile(bool isActive, String url) {
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
      CircleAvatar(
        radius: 20,
        backgroundImage: Image.network(url).image,
        backgroundColor: Colors.transparent, 
        child:
            isActive
                ? null
                : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(66, 0, 0, 0),
                  ),
                ),
      ),
    ],
  );
}
