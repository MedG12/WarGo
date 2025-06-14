import 'package:flutter/material.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/screens/user/detail_screen.dart';

Widget sellerCard(BuildContext context, Merchant seller) {
  return GestureDetector(
    onTap: () {
      // Navigate to detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(merchant: seller),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto/logo merchant
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: seller.imagePath != null
                ? Image.network(
                    seller.imagePath!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Info merchant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        seller.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Jarak (dummy)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          '2.3km', // Menggunakan hardcode 2.3km seperti di UI contoh
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  seller.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE3E7FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Color(0xFF6C63FF), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                seller.openHours ?? 'Tidak tersedia',
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        minimumSize: const Size(0, 32),
                        elevation: 0,
                      ),
                      child: const Text('Go'),
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