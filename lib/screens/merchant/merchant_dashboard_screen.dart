import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant/merchant_model.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';
import 'package:wargo/widgets/merchant/profile_card.dart';
import 'package:wargo/widgets/merchant/menu_card.dart';
import 'package:wargo/widgets/merchant/add_edit_menu_form.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  late String _merchantId;
  late MerchantService _merchantService;

  @override
  void initState() {
    super.initState();

    final authService = Provider.of<AuthService>(context, listen: false);
    _merchantId = authService.currentUser!.uid;
    _merchantService = Provider.of<MerchantService>(context, listen: false);

    _merchantService.ensureMerchantDataExists(
      _merchantId,
      authService.currentUser!.displayName ?? 'Merchant Baru',
      authService.currentUser!.photoURL,
    );
  }

  void _showAddMenuForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddEditMenuForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<MerchantModel?>(
              future: _merchantService.getMerchantProfile(_merchantId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        snapshot.hasError
                            ? 'Error: ${snapshot.error}'
                            : 'Profil merchant tidak ditemukan.',
                      ),
                    ),
                  );
                }
                final merchant = snapshot.data!;
                return MerchantProfileCard(merchant: merchant);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Menu Saya',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          StreamBuilder<List<MenuModel>>(
            stream: _merchantService.getMerchantMenus(_merchantId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Belum ada menu. Tambahkan menu baru!'),
                    ),
                  ),
                );
              }
              final menus = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final menu = menus[index];
                  return MenuCard(menu: menu);
                }, childCount: menus.length),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuForm(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Menu',
      ),
    );
  }
}
