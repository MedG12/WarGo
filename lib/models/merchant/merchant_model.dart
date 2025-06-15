import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantModel {
  final String uid; // Same as userId
  final String name; // Name of the merchant/shop
  final String? photoUrl; // Photo of the shop
  final String description;
  final String openHours;
  // final String distance; // Distance is usually calculated, not stored directly

  MerchantModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.description,
    required this.openHours,
  });

  // It's common to fetch merchant specific details and user details separately
  // For simplicity, if merchant name is same as user name, you can pass it
  factory MerchantModel.fromFirestore(
    DocumentSnapshot doc,
    String merchantName,
    String? merchantShopPhotoUrl,
  ) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MerchantModel(
      uid: doc.id,
      name: merchantName,
      photoUrl: merchantShopPhotoUrl,
      description: data['description'] ?? '',
      openHours: data['openHours'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'name': name, // Often derived or stored under user
      // 'photoUrl': photoUrl, // Often derived or stored under user or a separate shopPhotoUrl
      'description': description,
      'openHours': openHours,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'description': description,
      'openHours': openHours,
    };
  }
}
