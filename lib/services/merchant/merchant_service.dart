import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wargo/models/merchant/merchant_model.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/models/merchant/user_model.dart';
import 'package:wargo/services/merchant/storage_service.dart';
import 'package:wargo/services/merchant/user_service.dart';

class MerchantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  final String _merchantsCollectionPath = 'merchants';
  final String _menusSubcollectionName = 'menus';
  final String _supabaseBucketName = 'gerobakgo';

  // Get Merchant Profile
  // Future<MerchantModel?> getMerchantProfile(String userId) async {
  //   try {
  //     DocumentSnapshot merchantDoc =
  //         await _firestore
  //             .collection(_merchantsCollectionPath)
  //             .doc(userId)
  //             .get();

  //     UserModel? user = await _userService.getUser(userId);

  //     if (merchantDoc.exists && user != null) {
  //       final merchantData = merchantDoc.data() as Map<String, dynamic>?;

  //       String shopName = user.name;
  //       if (merchantData != null &&
  //           merchantData.containsKey('name') &&
  //           merchantData['name'] != null) {
  //         shopName = merchantData['name'] as String;
  //       }

  //       String? shopPhotoUrl = user.photoUrl;
  //       if (merchantData != null &&
  //           merchantData.containsKey('photoUrl') &&
  //           merchantData['photoUrl'] != null) {
  //         shopPhotoUrl = merchantData['photoUrl'] as String?;
  //       }

  //       return MerchantModel.fromFirestore(merchantDoc, shopName, shopPhotoUrl);
  //     }
  //     return null;
  //   } catch (e) {
  //     print("Error getting merchant profile: $e");
  //     return null;
  //   }
  // }

  // Stream Merchant Profile
  Stream<MerchantModel?> getMerchantProfile(String userId) {
    return _firestore
        .collection(_merchantsCollectionPath)
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (!snapshot.exists) return null;

          UserModel? user = await _userService.getUser(userId);
          if (user == null) return null;

          final merchantData = snapshot.data() as Map<String, dynamic>?;

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

          return MerchantModel.fromFirestore(snapshot, shopName, shopPhotoUrl);
        });
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
}
