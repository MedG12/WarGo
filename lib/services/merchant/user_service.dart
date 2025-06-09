import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wargo/models/merchant/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users';

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    required String role,
  }) async {
    await _firestore.collection(_collectionPath).doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.now(),
    });
  }

  Future<String?> getRole(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(uid).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error getting role: $e");
      return null;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }
}
