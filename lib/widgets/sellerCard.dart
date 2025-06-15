import 'package:flutter/material.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/screens/user/detail_screen.dart';

Widget sellerCard(BuildContext context, Merchant seller) {
  return GestureDetector(
    onTap: () async{
      // Navigate to detail screen
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(merchant: seller)),
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
        children: [
          // Merchant image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image:
                    (seller.imagePath != null &&
                            (seller.imagePath!.startsWith('http') ||
                                seller.imagePath!.startsWith('https')))
                        ? NetworkImage(seller.imagePath!) as ImageProvider
                        : const AssetImage('assets/images/placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Merchant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seller.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  seller.openHours ?? 'Jam buka tidak tersedia',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Distance and arrow
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              seller.distance == 'N/A'
                  ? Text('offline', style: TextStyle(color: Colors.grey))
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 16,
                      ),
                      Text(
                        seller.distance!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ),
    ),
  );
}
