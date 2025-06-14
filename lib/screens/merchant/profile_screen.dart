import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:wargo/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? profileImageFile;
  final MerchantService _merchantService = MerchantService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final merchant = await _merchantService.getMerchantProfile(user.uid);
      if (merchant != null) {
        setState(() {
          nameController.text = merchant.name;
          descriptionController.text = merchant.description ?? '';
          openHoursController.text = merchant.openHours ?? '';
          _currentPhotoUrl = merchant.photoUrl;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImageFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        String? newPhotoUrl = _currentPhotoUrl;
        
        // Upload foto baru jika ada
        if (profileImageFile != null) {
          newPhotoUrl = await _storageService.uploadImage(
            imageFile: profileImageFile!,
            bucketName: 'gerobakgo',
            path: 'merchants/${user.uid}',
          );
          
          // Hapus foto lama jika ada
          if (_currentPhotoUrl != null) {
            final oldPath = _storageService.extractPathFromUrl(
              _currentPhotoUrl!,
              'gerobakgo',
            );
            if (oldPath != null) {
              await _storageService.deleteImage(
                bucketName: 'gerobakgo',
                filePath: oldPath,
              );
            }
          }
        }

        // Update display name dan photo URL di Firebase Auth
        await user.updateDisplayName(nameController.text);
        if (newPhotoUrl != null) {
          await user.updatePhotoURL(newPhotoUrl);
        }
        
        // Update data di Firestore
        await _merchantService.updateMerchantProfile(
          user.uid,
          {
            'name': nameController.text,
            'description': descriptionController.text,
            'openHours': openHoursController.text,
            'photoUrl': newPhotoUrl,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      // Navigasi akan ditangani oleh AuthService melalui authStateChanges
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil Merchant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: _signOut,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Profile Photo
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageFile != null
                      ? FileImage(profileImageFile!)
                      : (_currentPhotoUrl != null
                          ? NetworkImage(_currentPhotoUrl!)
                          : const NetworkImage('https://placekitten.com/200/200')) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5D42D1),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Name Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Merchant', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF5D42D1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5D42D1), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Description Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF5D42D1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5D42D1), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Open Hours Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jam Operasional', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: openHoursController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF5D42D1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5D42D1), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF5D42D1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isLoading ? null : _updateProfile,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.edit, size: 18),
                label: Text(_isLoading ? 'Memperbarui...' : 'Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 