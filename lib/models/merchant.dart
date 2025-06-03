import 'package:latlong2/latlong.dart';

class Merchant {
  final String id;
  final String? imagePath;
  final String name;
  LatLng? location;
  String? distance;
  final String description;
  final String? openHours;

  Merchant({
    required this.id,
    this.imagePath,
    this.location,
    required this.name,
    this.distance,
    required this.description,
    this.openHours,
  });

  factory Merchant.fromMap(Map<String, dynamic> data) {
    return Merchant(
      id: data['id'],
      imagePath: data['photoUrl'],
      location: LatLng(data['lat'], data['lng']),
      name: data['name'],
      description: data['description'],
    );
  }
}

// Data dummy untuk list penjual
final List<Merchant> sellers = [
  Merchant(
    id: 'JvQU1c6VE1Zado6O361weVD4gGJ3',
    imagePath: 'assets/images/img_1.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    id: 'JvQU1c6VE1Zado6O361weVD4gGJ3',
    imagePath: 'assets/images/img_2.png',
    name: 'Siomay Uhuy', // Nama bisa berbeda, contoh menggunakan nama sama
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    id: 'JvQU1c6VE1Zado6O361weVD4gGJ3',
    imagePath: 'assets/images/img_3.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    id: 'JvQU1c6VE1Zado6O361weVD4gGJ3',
    imagePath: 'assets/images/img_4.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
];
