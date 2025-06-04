import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:wargo/utils/image_picker_utils.dart';

class AddEditMenuForm extends StatefulWidget {
  final MenuModel? menu;

  const AddEditMenuForm({super.key, this.menu});

  @override
  State<AddEditMenuForm> createState() => _AddEditMenuFormState();
}

class _AddEditMenuFormState extends State<AddEditMenuForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  File? _selectedImage;
  bool _isLoading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.menu?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.menu?.price.toString() ?? '',
    );
    _existingImageUrl = widget.menu?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    File? image = await ImagePickerUtils.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final merchantService = Provider.of<MerchantService>(
        context,
        listen: false,
      );
      final merchantId = authService.currentUser!.uid;

      final menuData = MenuModel(
        id: widget.menu?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: num.tryParse(_priceController.text.trim()) ?? 0,
        photoUrl: _existingImageUrl,
      );

      try {
        if (widget.menu == null) {
          // Add new menu
          await merchantService.addMenu(
            merchantId: merchantId,
            menu: menuData,
            imageFile: _selectedImage,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil ditambahkan!')),
          );
        } else {
          // Edit existing menu
          await merchantService.updateMenu(
            merchantId: merchantId,
            menu: menuData,
            imageFile: _selectedImage,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil diperbarui!')),
          );
        }
        Navigator.of(context).pop(); // Close bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan menu: $e')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.menu == null ? 'Tambah Menu Baru' : 'Edit Menu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child:
                      _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : (_existingImageUrl != null &&
                                  _existingImageUrl!.isNotEmpty
                              ? Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                              )
                              : Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[600],
                              )),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pilih Gambar Menu'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama menu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (num.tryParse(value) == null || num.parse(value) <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
