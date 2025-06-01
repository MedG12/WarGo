class MenuItem {
  final String imagePath;
  final String name;
  final String description;
  final int price;

  MenuItem({
    required this.imagePath,
    required this.name,
    required this.description,
    required this.price,
  });
}

// Data dummy untuk menu items
final List<MenuItem> menuItems = [
  MenuItem(
    imagePath: 'assets/images/siomay_1.jpg',
    name: 'Siomay',
    description: 'Isi siomay diukusan dari produk siomay yang ada di Siomay Uhuy',
    price: 10000,
  ),
  MenuItem(
    imagePath: 'assets/images/siomay_2.jpg',
    name: 'Siomay Komplit',
    description: 'Isi siomay diukusan dan produksimaunya komplit yang ada di Siomay Uhuy',
    price: 15000,
  ),
  MenuItem(
    imagePath: 'assets/images/siomay_1.jpg',
    name: 'Siomay',
    description: 'Isi siomay diukusan dari produk siomay yang ada di Siomay Uhuy',
    price: 10000,
  ),
  MenuItem(
    imagePath: 'assets/images/siomay_2.jpg',
    name: 'Siomay Komplit',
    description: 'Isi siomay diukusan dan produksimaunya komplit yang ada di Siomay Uhuy',
    price: 15000,
  ),
  MenuItem(
    imagePath: 'assets/images/siomay_1.jpg',
    name: 'Siomay',
    description: 'Isi siomay diukusan dari produk siomay yang ada di Siomay Uhuy',
    price: 10000,
  ),
  MenuItem(
    imagePath: 'assets/images/siomay_2.jpg',
    name: 'Siomay Komplit',
    description: 'Isi siomay diukusan dan produksimaunya komplit yang ada di Siomay Uhuy',
    price: 15000,
  ),
];