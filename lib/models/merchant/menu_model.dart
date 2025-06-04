import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String? id;
  final String name;
  final num price;
  final String description;
  final String? photoUrl;

  MenuModel({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.photoUrl,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'photoUrl': photoUrl,
    };
  }
}
