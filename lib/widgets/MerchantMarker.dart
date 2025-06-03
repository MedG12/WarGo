import 'package:flutter/material.dart';

Widget merchantMarker(String name, String? photoUrl) {
  final initials =
      name.isNotEmpty
          ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
          : '?';

  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.blue, // Warna border
        width: 2.0, // Ketebalan border
      ),
      // Opsional: tambahkan boxShadow
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
        ),
      ],
    ),
    child: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      backgroundImage:
          photoUrl != null && photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null,
      child:
          (photoUrl == null || photoUrl.isEmpty)
              ? Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              )
              : null,
    ),
  );
}
