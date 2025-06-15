import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:wargo/models/merchant/merchant_model.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/models/merchant/user_model.dart';
import 'package:wargo/services/merchant/storage_service.dart';
import 'package:wargo/services/merchant/user_service.dart';
import 'package:wargo/models/merchant.dart';

class MerchantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  final String _merchantsCollectionPath = 'merchants';
  final String _menusSubcollectionName = 'menus';
  final String _supabaseBucketName = 'gerobakgo';

  // Get Merchant Profile Stream
  Stream<MerchantModel?> getMerchantProfile(String userId) async* {
    try {
      UserModel? user = await _userService.getUser(userId);
      if (user == null) {
        yield null;
        return;
      }

      await for (final doc in _firestore
          .collection(_merchantsCollectionPath)
          .doc(userId)
          .snapshots()) {
        if (doc.exists) {
          final merchantData = doc.data() as Map<String, dynamic>?;

          String shopName = user.name;
          if (merchantData != null &&
              merchantData.containsKey('name') &&
              merchantData['name'] != null) {
            shopName = merchantData['name'] as String;
          }

          String? shopPhotoUrl = user.photoUrl;
          if (merchantData != null &&
              merchantData.containsKey('photoUrl') &&
              merchantData['photoUrl'] != null) {
            shopPhotoUrl = merchantData['photoUrl'] as String?;
          }

          yield MerchantModel.fromFirestore(doc, shopName, shopPhotoUrl);
        } else {
          yield null;
        }
      }
    } catch (e) {
      print("Error in merchant profile stream: $e");
      yield null;
    }
  }

  // Stream Merchant Menus
  Stream<List<MenuModel>> getMerchantMenus(String merchantId) {
    return _firestore
        .collection(_merchantsCollectionPath)
        .doc(merchantId)
        .collection(_menusSubcollectionName)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList(),
        );
  }

  // Add Menu
  Future<void> addMenu({
    required String merchantId,
    required MenuModel menu,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          imageFile: imageFile,
          bucketName: _supabaseBucketName,
          path: 'menus/$merchantId',
        );
      }

      MenuModel menuWithImage = MenuModel(
        name: menu.name,
        price: menu.price,
        description: menu.description,
        photoUrl: imageUrl ?? menu.photoUrl,
      );

      await _firestore
          .collection(_merchantsCollectionPath)
          .doc(merchantId)
          .collection(_menusSubcollectionName)
          .add(menuWithImage.toMap());
    } catch (e) {
      print("Error adding menu: $e");
      rethrow;
    }
  }

  // Update Menu
  Future<void> updateMenu({
    required String merchantId,
    required MenuModel menu,
    File? imageFile,
  }) async {
    try {
      String? newImageUrl = menu.photoUrl;
      String? oldPhotoUrlToDelete = null;

      if (imageFile != null) {
        // 1. Ada gambar baru yang dipilih, unggah gambar baru
        print("New image file provided for update. Uploading...");
        String? uploadedUrl = await _storageService.uploadImage(
          imageFile: imageFile,
          bucketName: _supabaseBucketName,
          path: 'menus/$merchantId',
        );

        if (uploadedUrl != null) {
          newImageUrl = uploadedUrl;
          // Jika ada URL gambar lama yang valid dan berbeda dari yang baru, tandai untuk dihapus
          if (menu.photoUrl != null &&
              menu.photoUrl!.isNotEmpty &&
              menu.photoUrl != newImageUrl) {
            oldPhotoUrlToDelete = menu.photoUrl;
          }
          print(
            "New image uploaded. New URL: $newImageUrl. Old URL to delete: $oldPhotoUrlToDelete",
          );
        } else {
          print(
            "Failed to upload new image. Update process for image aborted.",
          );
        }
      }

      // 2. Buat data menu yang akan diupdate di Firestore
      MenuModel updatedMenuData = MenuModel(
        id: menu.id,
        name: menu.name,
        price: menu.price,
        description: menu.description,
        photoUrl: newImageUrl,
      );

      // 3. Update dokumen menu di Firestore
      await _firestore
          .collection(_merchantsCollectionPath)
          .doc(merchantId)
          .collection(_menusSubcollectionName)
          .doc(menu.id)
          .update(updatedMenuData.toMap());
      print("Menu document ${menu.id} updated in Firestore.");

      // 4. Jika ada gambar lama yang perlu dihapus (karena berhasil diganti dengan yang baru)
      if (oldPhotoUrlToDelete != null) {
        print(
          "Attempting to delete old image from Supabase: $oldPhotoUrlToDelete",
        );
        final String? filePathToDelete = _storageService.extractPathFromUrl(
          oldPhotoUrlToDelete,
          _supabaseBucketName,
        );

        if (filePathToDelete != null && filePathToDelete.isNotEmpty) {
          bool deleted = await _storageService.deleteImage(
            bucketName: _supabaseBucketName,
            filePath: filePathToDelete,
          );
          if (deleted) {
            print(
              "Old image $filePathToDelete successfully deleted from Supabase.",
            );
          } else {
            print(
              "Failed to delete old image $filePathToDelete from Supabase, or image not found.",
            );
          }
        } else {
          print(
            "Could not extract file path from old URL: $oldPhotoUrlToDelete. Old image not deleted.",
          );
        }
      }
    } catch (e) {
      print("Error updating menu: $e");
      rethrow;
    }
  }

  // Delete Menu
  Future<void> deleteMenu({
    required String merchantId,
    required String menuId,
    String? photoUrl,
  }) async {
    try {
      await _firestore
          .collection(_merchantsCollectionPath)
          .doc(merchantId)
          .collection(_menusSubcollectionName)
          .doc(menuId)
          .delete();
      print(
        "Menu document $menuId deleted from Firestore for merchant $merchantId.",
      );

      if (photoUrl != null && photoUrl.isNotEmpty) {
        final String? filePath = _storageService.extractPathFromUrl(
          photoUrl,
          _supabaseBucketName,
        );
        if (filePath != null && filePath.isNotEmpty) {
          print(
            "Attempting to delete image from Supabase. URL: $photoUrl, Extracted Path: $filePath",
          );
          bool deleted = await _storageService.deleteImage(
            bucketName: _supabaseBucketName,
            filePath: filePath,
          );
          if (deleted) {
            print(
              "Image $filePath successfully deleted from Supabase bucket $_supabaseBucketName.",
            );
          } else {
            print(
              "Failed to delete image $filePath from Supabase bucket $_supabaseBucketName, or image not found.",
            );
          }
        } else {
          print(
            "Could not extract a valid file path from URL: $photoUrl. Image not deleted from Supabase.",
          );
        }
      } else {
        print(
          "No photoUrl provided for menu $menuId, skipping Supabase image deletion.",
        );
      }
    } catch (e) {
      print("Error deleting menu or its associated image: $e");
      rethrow;
    }
  }

  // Fungsi untuk membuat/update data merchant dasar jika belum ada
  Future<void> ensureMerchantDataExists(
    String userId,
    String userName,
    String? userPhotoUrl,
  ) async {
    final merchantDocRef = _firestore
        .collection(_merchantsCollectionPath)
        .doc(userId);
    final merchantDoc = await merchantDocRef.get();

    if (!merchantDoc.exists) {
      await merchantDocRef.set({
        // 'name': userName,
        // 'photoUrl': userPhotoUrl,
        'description': 'Deskripsi toko belum diatur.',
        'openHours': '08.00 - 17.00',
      });
    }
  }

  Future<void> updateMerchantProfile({
    required String userId,
    required String name,
    required String description,
    required String openHours,
    String? photoUrl,
  }) async {
    try {
      // Update data merchant di collection merchants
      final merchantData = {
        'name': name,
        'description': description,
        'openHours': openHours,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_merchantsCollectionPath)
          .doc(userId)
          .update(merchantData);

      // Update data user di collection users
      final userData = {
        'name': name,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .update(userData);
    } catch (e) {
      print('Error updating merchant profile: $e');
      rethrow;
    }
  }

  Stream<List<MerchantModel>> getMerchants() async* {
    try {
      await for (final snapshot in _firestore.collection(_merchantsCollectionPath).snapshots()) {
        List<MerchantModel> merchants = [];
        
        for (final doc in snapshot.docs) {
          final user = await _userService.getUser(doc.id);
          if (user != null) {
            final data = doc.data();
            String shopName = user.name;
            if (data.containsKey('name') && data['name'] != null) {
              shopName = data['name'] as String;
            }

            String? shopPhotoUrl = user.photoUrl;
            if (data.containsKey('photoUrl') && data['photoUrl'] != null) {
              shopPhotoUrl = data['photoUrl'] as String?;
            }

            merchants.add(MerchantModel.fromFirestore(doc, shopName, shopPhotoUrl));
          }
        }
        
        yield merchants;
      }
    } catch (e) {
      print("Error getting merchants: $e");
      yield [];
    }
  }
}
