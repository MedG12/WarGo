import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/screens/user/chat_details_screen.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/services/notification_service.dart';
import 'package:wargo/widgets/MerchantMarker.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const MapScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final locationService = LocationService();
    final proximityService = ProximityAlertService();
    final isMerchant = authService.role == 'merchant';
    final user = authService.currentUser;

    String getInitials(String name) {
      return name
          .trim()
          .split(' ')
          .map((e) => e[0])
          .take(2)
          .join()
          .toUpperCase();
    }

    void showMerchantModal(BuildContext context, Merchant merchant) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      merchant.imagePath != null &&
                              merchant.imagePath!.isNotEmpty
                          ? NetworkImage(merchant.imagePath!)
                          : null,
                  child:
                      merchant.imagePath == null || merchant.imagePath!.isEmpty
                          ? Text(
                            getInitials(merchant.name),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  merchant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  merchant.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Button: Ingatkan Saya
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Ingatkan Saya'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      proximityService.addTaggedMerchant(merchant.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Button: Kirim Pesan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Pesan'),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatDetailsScreen(
                                title: merchant.name,
                                peerId: merchant.id,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return StreamBuilder<Position>(
      stream: locationService.getLocationStream(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userPosition = userSnapshot.data!;

        if (userSnapshot.hasData && isMerchant) {
          locationService.updateLocationToFirebase(userPosition, user!.uid);
        }

        final userLatLng = LatLng(
          userPosition.latitude,
          userPosition.longitude,
        );

        return StreamBuilder<List<Merchant>>(
          stream: locationService.getLiveMerchants(),
          builder: (context, snapshot) {
            final markers = <Marker>[
              if (!isMerchant)
                Marker(
                  point: userLatLng,
                  child: const Icon(Icons.circle, size: 20, color: Colors.blue),
                ),
            ];

            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final taggedMerchants =
                    await proximityService.getTaggedMerchants();
                if (taggedMerchants.isNotEmpty) {
                  proximityService.checkProximity(snapshot.data!, userPosition);
                }
              });

              for (final merchant in snapshot.data!) {
                if (merchant.location == null) continue;

                // Marker untuk user saat ini
                if (merchant.id == user!.uid) {
                  markers.add(
                    Marker(
                      point: merchant.location!,
                      child: const Icon(
                        Icons.circle,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                  );
                } else {
                  markers.add(
                    Marker(
                      point: merchant.location!,
                      child: GestureDetector(
                        onTap: () => showMerchantModal(context, merchant),
                        child: merchantMarker(
                          merchant.name,
                          merchant.imagePath,
                        ),
                      ),
                    ),
                  );
                }
              }
            }
            print('widget.initialLocation: ${widget.initialLocation}');
            return Scaffold(
              body: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: widget.initialLocation ?? userLatLng,
                  initialZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  mapController.move(userLatLng, 18);
                },
                child: const Icon(Icons.my_location),
              ),
            );
          },
        );
      },
    );
  }
}
