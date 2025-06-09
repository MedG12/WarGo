import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? photoUrl,
  }) async {
    final docSnapshot = await users.doc(uid).get();
    if (!docSnapshot.exists) {
      await users.doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> getRole(String uid) async {
    final docSnapshot = await users.doc(uid).get();
    return docSnapshot['role'];
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final doc = await users.doc(uid).get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }
}
