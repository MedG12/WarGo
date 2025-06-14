import 'package:flutter/material.dart';
import 'package:wargo/models/merchant/merchant_model.dart';
import 'package:wargo/services/merchant_service.dart';

class MerchantList extends StatelessWidget {
  final MerchantService _merchantService = MerchantService();

  MerchantList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MerchantModel>>(
      stream: _merchantService.getMerchants(),
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
            child: Text('Belum ada merchant yang terdaftar'),
          );
        }

        final merchants = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: merchants.length,
          itemBuilder: (context, index) {
            final merchant = merchants[index];
            return MerchantCard(merchant: merchant);
          },
        );
      },
    );
  }
}

class MerchantCard extends StatelessWidget {
  final MerchantModel merchant;

  const MerchantCard({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto/logo merchant
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: merchant.photoUrl != null
                  ? Image.network(
                merchant.photoUrl!,
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
                          merchant.name,
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
                            '2.3km',
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
                    merchant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
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
                      const SizedBox(width: 12),
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
                              merchant.openHours,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOpenHours(String openHours) {
    return openHours;
  }
}