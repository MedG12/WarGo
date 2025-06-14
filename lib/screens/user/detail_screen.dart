import 'package:flutter/material.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:provider/provider.dart';

const Color primaryColor = Color(0xFF0E2148);
const Color goButtonColor = Color(0xFF5825DF);

// Function untuk format rupiah tanpa package intl
String formatRupiah(num amount) {
  String result = amount.toInt().toString();
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

class DetailScreen extends StatelessWidget {
  final Merchant merchant;

  const DetailScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchantService = Provider.of<MerchantService>(context, listen: false);

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
                      image: merchant.imagePath != null
                          ? DecorationImage(
                              image: NetworkImage(merchant.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: merchant.imagePath == null
                        ? Icon(
                            Icons.store,
                            size: 30,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Info merchant (nama + deskripsi + GO button)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // GO button di bawah deskripsi
                        Align(
                          alignment: Alignment.centerLeft,
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
                      ],
                    ),
                  ),

                  // Jarak dan Update terakhir (kanan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (merchant.distance != null)
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
                              merchant.distance!,
                              style: const TextStyle(
                                fontSize: 14,
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
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '1 jam lalu',
                            style: TextStyle(
                              fontSize: 9,
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
                      stream: merchantService.getMerchantMenus(merchant.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Belum ada menu yang tersedia'),
                          );
                        }

                        final menus = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: menus.length,
                          itemBuilder: (context, index) {
                            final menu = menus[index];
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
                                      image: menu.photoUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(menu.photoUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: menu.photoUrl == null
                                        ? Icon(
                                            Icons.fastfood,
                                            size: 30,
                                            color: Colors.grey[400],
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),

                                  // Menu info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menu.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          menu.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatRupiah(menu.price),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
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