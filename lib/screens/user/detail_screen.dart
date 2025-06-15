import 'package:flutter/material.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/services/merchant/merchant_service.dart';

const Color primaryColor = Color(0xFF0E2148);
const Color goButtonColor = Color(0xFF5825DF);

// Function untuk format rupiah tanpa package intl
String formatRupiah(int amount) {
  String result = amount.toString();
  String formattedResult = '';

  // Tambahkan titik setiap 3 digit dari belakang
  for (int i = result.length - 1; i >= 0; i--) {
    formattedResult = result[i] + formattedResult;
    if ((result.length - i) % 3 == 0 && i != 0) {
      formattedResult = '.' + formattedResult;
    }
  }

  return 'Rp $formattedResult';
}

class DetailScreen extends StatefulWidget {
  final Merchant merchant;

  const DetailScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final MerchantService _merchantService = MerchantService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Balance untuk center title
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Merchant info (TANPA card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo merchant
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: (widget.merchant.imagePath != null &&
                                (widget.merchant.imagePath!.startsWith('http') ||
                                    widget.merchant.imagePath!.startsWith('https')))
                            ? NetworkImage(widget.merchant.imagePath!) as ImageProvider
                            : const AssetImage('assets/images/placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info merchant (nama + deskripsi + GO button)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.merchant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.merchant.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          // Hapus maxLines dan overflow agar tampil semua
                        ),
                        const SizedBox(height: 8),
                        // GO button di bawah deskripsi
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              print('GO button tapped!'); // Action for GO button
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: goButtonColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'GO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Jarak dan Update terakhir (kanan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Jarak di atas (diperbesar)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.merchant.distance!,
                            style: const TextStyle(
                              fontSize: 14, // Diperbesar dari 12 ke 14
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Terakhir update multiline (diperkecil)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Terakhir update',
                            style: TextStyle(
                              fontSize: 9, // Diperkecil dari 11 ke 9
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '1 jam lalu',
                            style: TextStyle(
                              fontSize: 9, // Diperkecil dari 11 ke 9
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu list
                  Expanded(
                    child: StreamBuilder<List<MenuModel>>(
                      stream: _merchantService.getMerchantMenus(widget.merchant.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final menus = snapshot.data ?? [];

                        if (menus.isEmpty) {
                          return const Center(
                            child: Text('Belum ada menu yang tersedia'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: menus.length,
                          itemBuilder: (context, index) {
                            final menuItem = menus[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  // Menu image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: (menuItem.photoUrl != null &&
                                                (menuItem.photoUrl!.startsWith('http') ||
                                                    menuItem.photoUrl!.startsWith('https')))
                                            ? NetworkImage(menuItem.photoUrl!) as ImageProvider
                                            : const AssetImage('assets/images/placeholder.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Menu info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menuItem.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          menuItem.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatRupiah(menuItem.price.toInt()),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}