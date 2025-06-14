import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/widgets/sellerCard.dart';

// Definisikan warna utama
const Color primaryColor = Color(0xFF0E2148);
const Color textLightColor = Colors.white;
const Color textDarkColor = Colors.black87;
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
              expandedHeight: 250,
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
                      height: 300,
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
            StreamBuilder<List<Merchant>>(
              stream: context.read<LocationService>().getAllMerchants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('Belum ada merchant yang terdaftar'),
                    ),
                  );
                }

                final merchants = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return sellerCard(context, merchants[index]);
                    },
                    childCount: merchants.length,
                  ),
                );
              },
            ),
            // Menambahkan ruang kosong di bagian bawah untuk BottomNavigationBar
            const SliverToBoxAdapter(child: SizedBox(height: 250)),
          ],
        ),
      ),
    );
  }
}
