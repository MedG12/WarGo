import 'package:flutter/material.dart';

// Definisikan warna utama
const Color primaryColor = Color(0xFF0E2148);
const Color textLightColor =
    Colors.white; // Warna teks di atas background gelap
const Color textDarkColor =
    Colors.black87; // Warna teks di atas background terang
const Color textMutedColor = Colors.grey;

// Model data sederhana untuk penjual
class Seller {
  final String imagePath;
  final String name;
  final String distance;
  final String description;
  final String openHours;

  Seller({
    required this.imagePath,
    required this.name,
    required this.distance,
    required this.description,
    required this.openHours,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Data dummy untuk list penjual
  final List<Seller> sellers = [
    Seller(
      imagePath: 'assets/images/img_1.png',
      name: 'Siomay Uhuy',
      distance: '2.3km',
      description:
          'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
      openHours: '9:00 AM - 8:00 PM',
    ),
    Seller(
      imagePath: 'assets/images/img_2.png',
      name: 'Siomay Uhuy', // Nama bisa berbeda, contoh menggunakan nama sama
      distance: '2.3km',
      description:
          'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
      openHours: '9:00 AM - 8:00 PM',
    ),
    Seller(
      imagePath: 'assets/images/img_3.png',
      name: 'Siomay Uhuy',
      distance: '2.3km',
      description:
          'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
      openHours: '9:00 AM - 8:00 PM',
    ),
    Seller(
      imagePath: 'assets/images/img_4.png',
      name: 'Siomay Uhuy',
      distance: '2.3km',
      description:
          'Siomay ikan, pangsit, tahu, dll. Dengan topping saus kacang yang pedas gurih.',
      openHours: '9:00 AM - 8:00 PM',
    ),
  ];

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          isDense: true,
          contentPadding: EdgeInsets.only(left: 8, right: 8),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Seller seller) {
    const double imageHeight = 100.0; // Tentukan tinggi gambar yang konsisten

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(
          12.0,
        ), // Padding untuk seluruh konten di dalam card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar di Kiri
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                seller.imagePath,
                width: 80,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 80,
                      height: imageHeight,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // Bagian Konten di Kanan
            Expanded(
              child: SizedBox(
                // Bungkus Column dengan SizedBox untuk membatasi tingginya
                height: imageHeight, // Samakan tinggi dengan gambar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Distribusikan ruang vertikal
                  children: [
                    // Grup Atas: Nama, Jarak, Deskripsi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                seller.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDarkColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
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
                        const SizedBox(height: 4),
                        Text(
                          seller.description,
                          style: TextStyle(fontSize: 12, color: textMutedColor),
                          maxLines:
                              2, // Sesuaikan jika deskripsi bisa lebih panjang atau pendek
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Grup Bawah: Jam Buka dan Tombol Go dalam satu Row
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween, // Jam buka di kiri, tombol di kanan
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center, // Sejajarkan secara vertikal
                      children: [
                        // Jam Buka
                        Row(
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
                            ),
                          ],
                        ),
                        // Tombol Go
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Menuju ke ${seller.name}'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, // Warna dari tema
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                18.0,
                              ), // Tombol lebih bulat
                            ),
                            elevation: 2, // Sedikit shadow jika diinginkan
                          ),
                          child: const Text(
                            'Go',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/img_city.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: _buildSearchBar(),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "What's on",
                    style: TextStyle(
                      color: textLightColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Lokasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: textLightColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Depok",
                        style: TextStyle(color: textLightColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                      ), // Padding untuk list
                      itemCount: sellers.length,
                      itemBuilder: (context, index) {
                        return _buildSellerCard(context, sellers[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Tambahkan logika navigasi di sini jika diperlukan
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false, // Tidak tampilkan label
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.home_outlined, Icons.home, 0),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.map_outlined, Icons.map, 1),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              Icons.chat_bubble_outline,
              Icons.chat_bubble,
              2,
            ),
            label: "",
          ),
          BottomNavigationBarItem(icon: _buildNavProfileItem(3), label: ""),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, int index) {
    bool isActive = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            height: 2,
            width: 40,
            color: primaryColor,
          ),
        Icon(isActive ? filledIcon : outlinedIcon),
      ],
    );
  }

  Widget _buildNavProfileItem(int index) {
    bool isActive = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            height: 2,
            width: 40,
            color: primaryColor,
          ),
        CircleAvatar(
          radius: 12,
          backgroundImage: AssetImage('assets/images/img_profile.png'),
          backgroundColor:
              Colors.transparent, // Jika gambar sudah ada background
          child:
              isActive
                  ? null
                  : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(66, 0, 0, 0),
                    ),
                  ),
        ),
      ],
    );
  }
}
