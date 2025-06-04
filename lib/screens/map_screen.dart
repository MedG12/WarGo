import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wargo/models/merchant.dart';
import 'package:wargo/services/auth_service.dart';
import 'package:wargo/services/location_service.dart';
import 'package:wargo/services/notification_service.dart';
import 'package:wargo/widgets/MerchantMarker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

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
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        merchant.imagePath != null &&
                                merchant.imagePath!.isNotEmpty
                            ? NetworkImage(merchant.imagePath!)
                            : null,
                    child:
                        merchant.imagePath == null ||
                                merchant.imagePath!.isEmpty
                            ? Text(
                              getInitials(merchant.name),
                              style: TextStyle(fontSize: 24),
                            )
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    merchant.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    merchant.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.notifications_active),
                    label: Text('Ingatkan Saya'),
                    onPressed: () {
                      proximityService.addTaggedMerchant(merchant.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
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
          stream: locationService.getAllMerchants(),
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
            return Scaffold(
              body: FlutterMap(
                mapController: mapController,
                options: MapOptions(initialCenter: userLatLng, initialZoom: 18),
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
