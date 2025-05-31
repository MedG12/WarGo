import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/widgets/sellerCard.dart';
import 'package:provider/provider.dart';

// Definisikan warna utama
const Color primaryColor = Color(0xFF0E2148);
const Color textLightColor =
    Colors.white; // Warna teks di atas background gelap
const Color textDarkColor =
    Colors.black87; // Warna teks di atas background terang
const Color textMutedColor = Colors.grey;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    String? currentCity = context.watch<LocationService>().currentCity;
    SearchController _searchController = SearchController();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250, // Tinggi gambar
              backgroundColor: primaryColor,
              floating: false,
              pinned: true,
              toolbarHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20.0),
                background: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/img_city.png',
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300, // Sesuaikan tinggi gambar
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's on",
                            style: TextStyle(
                              color: textLightColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_sharp,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              Flexible(
                                child: Text(
                                  currentCity ?? 'Please wait...',
                                  style: TextStyle(
                                    color: textLightColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
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
              title: SizedBox(
                height: 45,
                child: SearchBar(
                  controller: _searchController,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  hintText: 'Cari disini...',
                  trailing: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ), // Atur radius sesuai kebutuhan
                child: Container(
                  color: Colors.white, // Warna background container
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      return sellerCard(context, sellers[index]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
