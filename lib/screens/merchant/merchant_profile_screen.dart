import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:wargo/services/merchant/storage_service.dart';
import 'package:wargo/models/merchant/merchant_model.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({Key? key}) : super(key: key);

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  final ImagePicker _picker = ImagePicker();
  String? profileImagePath;
  bool isLoading = false;
  final MerchantService _merchantService = MerchantService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMerchantData();
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

  Future<void> _loadMerchantData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      try {
        final merchantDoc =
            await _merchantService.getMerchantProfile(user.uid).first;
        if (merchantDoc != null) {
          print(
            'Loading merchant data: ${merchantDoc.toJson()}',
          ); // Debug print
          setState(() {
            nameController.text = merchantDoc.name;
            descriptionController.text = merchantDoc.description;
            if (merchantDoc.openHours.isNotEmpty) {
              final times = merchantDoc.openHours.split(' - ');
              if (times.length == 2) {
                openTime = _parseTimeString(times[0]);
                closeTime = _parseTimeString(times[1]);
                print(
                  'Parsed times - Open: $openTime, Close: $closeTime',
                ); // Debug print
              }
            }
          });
        } else {
          print('No merchant data found'); // Debug print
        }
      } catch (e) {
        print('Error loading merchant data: $e');
      }
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      print('Parsing time string: $timeStr'); // Debug print

      // Coba format "HH:mm"
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1].split(' ')[0]);
          final time = TimeOfDay(hour: hour, minute: minute);
          print('Parsed time: $time'); // Debug print
          return time;
        }
      }

      // Coba format "HH.mm"
      if (timeStr.contains('.')) {
        final parts = timeStr.split('.');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1].split(' ')[0]);
          final time = TimeOfDay(hour: hour, minute: minute);
          print('Parsed time: $time'); // Debug print
          return time;
        }
      }

      print('Could not parse time string: $timeStr');
    } catch (e) {
      print('Error parsing time: $e');
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isOpenTime
              ? (openTime ?? TimeOfDay.now())
              : (closeTime ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5D42D1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    if (openTime == null || closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam buka dan tutup harus diisi')),
      );
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
          path: 'merchants/${user.uid}/profile',
        );
      }

      // Format jam buka
      final openHours =
          '${_formatTimeOfDay(openTime!)} - ${_formatTimeOfDay(closeTime!)}';

      // Update data di Firestore
      await _merchantService.updateMerchantProfile(
        userId: user.uid,
        name: nameController.text,
        description: descriptionController.text,
        openHours: openHours,
        photoUrl: photoUrl,
      );

      // Update display name dan photo URL di Firebase Auth
      await user.updateDisplayName(nameController.text);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        // Refresh data tanpa navigasi
        _loadMerchantData();
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
    final displayName = user?.displayName ?? 'Merchant';

    String getInitials(String name) {
      if (name.isEmpty) return "?";

      List<String> names = name.split(' ');
      if (names.length == 1) return names[0][0].toUpperCase();

      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
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
                        'Profil Merchant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () async {
                          await Provider.of<AuthService>(
                            context,
                            listen: false,
                          ).signOut();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Profile Photo
                Stack(
                  children: [
                    profileImagePath != null
                        ? CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(File(profileImagePath!)),
                        )
                        : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            getInitials(displayName),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        'Nama Toko',
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
                // Description Field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
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
                // Open Hours Fields
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jam Buka',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF5D42D1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  openTime != null
                                      ? _formatTimeOfDay(openTime!)
                                      : 'Pilih jam buka',
                                  style: TextStyle(
                                    color:
                                        openTime != null
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text('sampai'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF5D42D1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  closeTime != null
                                      ? _formatTimeOfDay(closeTime!)
                                      : 'Pilih jam tutup',
                                  style: TextStyle(
                                    color:
                                        closeTime != null
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
