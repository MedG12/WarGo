import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/models/merchant/merchant_model.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:wargo/widgets/sellerCard.dart';

// Warna
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
  final AuthService authService = AuthService();
  final MerchantService _merchantService = MerchantService();
  final SearchController _searchController = SearchController();

  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchKeyword = _searchController.text.toLowerCase();
    });
  }

  List<MerchantModel> _filterMerchants(List<MerchantModel> merchants) {
    if (_searchKeyword.isEmpty) return merchants;
    return merchants.where((merchant) {
      final name = merchant.name?.toLowerCase() ?? '';
      return name.contains(_searchKeyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String? currentCity = context.watch<LocationService>().currentCity;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250, // Tinggi gambar
              backgroundColor: Colors.transparent,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's on",
                            style: const TextStyle(
                              color: textLightColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_sharp,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              Flexible(
                                child: Text(
                                  currentCity ?? 'Please wait...',
                                  style: const TextStyle(
                                    color: textLightColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                      onPressed: () {
                        // Optional jika ingin trigger search manual
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),

            StreamBuilder<List<MerchantModel>>(
              stream: _merchantService.getMerchants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                final merchants = snapshot.data ?? [];
                final filteredMerchants = _filterMerchants(merchants);

                if (filteredMerchants.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada merchant yang cocok.'),
                    ),
                  );
                }

                return SliverFillRemaining(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: filteredMerchants.length,
                        itemBuilder: (context, index) {
                          final merchant = filteredMerchants[index];
                          return sellerCard(
                            context,
                            Merchant(
                              id: merchant.uid,
                              name: merchant.name,
                              description: merchant.description,
                              imagePath: merchant.photoUrl,
                              distance: '2.3km',
                              openHours: merchant.openHours,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
