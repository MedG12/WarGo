import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        // options: MapOptions(initialCenter: LatLng(0, 0), initialZoom: 10),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          // MarkerLayer(
          //   markers:
          //       allDeviceLocations.entries.map((entry) {
          //         return Marker(
          //           point: entry.value,
          //           child: Icon(
          //             entry.key == widget.deviceId
          //                 ? Icons.person_pin_circle
          //                 : Icons.location_pin,
          //             size: 40,
          //             color:
          //                 entry.key == widget.deviceId
          //                     ? Colors.red
          //                     : Colors.blue,
          //           ),
          //         );
          //       }).toList(),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () => {},
      ),
    );
  }
}
