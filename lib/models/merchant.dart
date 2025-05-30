class Merchant {
  final String imagePath;
  final String name;
  final String distance;
  final String description;
  final String openHours;

  Merchant({
    required this.imagePath,
    required this.name,
    required this.distance,
    required this.description,
    required this.openHours,
  });
}

// Data dummy untuk list penjual
final List<Merchant> sellers = [
  Merchant(
    imagePath: 'assets/images/img_1.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    imagePath: 'assets/images/img_2.png',
    name: 'Siomay Uhuy', // Nama bisa berbeda, contoh menggunakan nama sama
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    imagePath: 'assets/images/img_3.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
  Merchant(
    imagePath: 'assets/images/img_4.png',
    name: 'Siomay Uhuy',
    distance: '2.3km',
    description:
        'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
    openHours: '9:00 AM - 8:00 PM',
  ),
];
