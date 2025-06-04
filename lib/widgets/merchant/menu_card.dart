import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant/menu_model.dart';
import 'package:wargo/widgets/merchant/add_edit_menu_form.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/merchant/merchant_service.dart';

class MenuCard extends StatefulWidget {
  final MenuModel menu;

  const MenuCard({super.key, required this.menu});

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  void _showEditMenuForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditMenuForm(menu: widget.menu),
    );
  }

  void _confirmDeleteMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Menu'),
          content: Text(
            'Apakah Anda yakin ingin menghapus menu "${widget.menu.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red[700])),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                if (!mounted) return;

                try {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  final merchantService = Provider.of<MerchantService>(
                    context,
                    listen: false,
                  );

                  await merchantService.deleteMenu(
                    merchantId: authService.currentUser!.uid,
                    menuId: widget.menu.id!,
                    photoUrl: widget.menu.photoUrl,
                  );

                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Menu berhasil dihapus')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Gagal menghapus menu: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:
                  widget.menu.photoUrl != null &&
                          widget.menu.photoUrl!.isNotEmpty
                      ? Image.network(
                        widget.menu.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey[400],
                              ),
                            ),
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(Icons.fastfood, color: Colors.grey[400]),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(widget.menu.price),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.menu.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _showEditMenuForm(context),
                  tooltip: 'Edit Menu',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => _confirmDeleteMenu(context),
                  tooltip: 'Hapus Menu',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
