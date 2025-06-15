import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/user_service.dart';
import 'package:wargo/services/merchant/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? profileImagePath;
  bool isLoading = false;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      setState(() {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
      });
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return "?";

    List<String> names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();

    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      String? photoUrl;
      if (profileImagePath != null) {
        // Upload foto profil ke storage
        photoUrl = await _storageService.uploadImage(
          imageFile: File(profileImagePath!),
          bucketName: 'gerobakgo',
          path: 'users/${user.uid}/profile',
        );
      }

      // Update data di Firestore
      await _userService.updateUser(user.uid, {
        'name': nameController.text,
        'photoUrl': photoUrl,
      });

      // Update display name di Firebase Auth
      await user.updateDisplayName(nameController.text);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImagePath = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final currentPhotoUrl = user?.photoURL;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () async {
                        await authService.signOut();
                      },
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
                    backgroundImage:
                        profileImagePath != null
                            ? FileImage(File(profileImagePath!))
                            : (Provider.of<AuthService>(
                                      context,
                                    ).currentUser?.photoURL !=
                                    null
                                ? NetworkImage(
                                      Provider.of<AuthService>(
                                        context,
                                      ).currentUser!.photoURL!,
                                    )
                                    as ImageProvider
                                : null),
                    child:
                        profileImagePath == null &&
                                Provider.of<AuthService>(
                                      context,
                                    ).currentUser?.photoURL ==
                                    null
                            ? Text(
                              getInitials(user?.displayName ?? ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null, // Jangan tampilkan child jika ada gambar
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Name Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF5D42D1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5D42D1),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
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
                    iconColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFF5D42D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading ? null : _updateProfile,
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.edit, size: 18),
                  label: Text(
                    isLoading ? 'Memperbarui...' : 'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
