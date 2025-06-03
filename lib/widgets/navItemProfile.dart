import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/services/auth_service.dart';

Widget navItemProfile(context, bool isActive) {
  final authService = Provider.of<AuthService>(context);
  final user = authService.currentUser;
  final photoURL = user?.photoURL;
  final displayName = user?.displayName ?? 'User';
  String getInitials(String name) {
    if (name.isEmpty) return "?";

    List<String> names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();

    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  return Container(
    decoration:
        isActive
            ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              shape: BoxShape.circle,
            )
            : null,
    child:
        photoURL != null
            ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(photoURL))
            : CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent,
              child: Text(
                getInitials(displayName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
  );
}
