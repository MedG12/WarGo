import 'package:flutter/material.dart';
import 'package:wargo/models/merchant.dart';

Widget sellerCard(BuildContext context, Merchant seller) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color.fromARGB(255, 239, 238, 238), width: 0.5),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar di Kiri
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              seller.imagePath,
              width: 80,
              height: 80, // Fixed height untuk gambar
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),

          // Konten di Kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Baris Nama dan Jarak
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        seller.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.orangeAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          seller.distance,
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Deskripsi dengan tinggi maksimum
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 40,
                  ), // 2 baris text
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    seller.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Baris Jam Buka dan Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            seller.openHours,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueAccent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Menuju ke ${seller.name}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          0xFF5825DF,
                        ), // Sesuaikan dengan tema
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero, // Tombol lebih compact
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Go',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
