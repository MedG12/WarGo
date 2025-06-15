import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargo/models/merchant.dart';

class LocationService extends ChangeNotifier {
  String? _currentCity;
  DateTime? _lastUpdated;
  final _dbRef = FirebaseDatabase.instance.ref();
  // Stream<Position> posisi = Position(0, 0).asStream();

  String? get currentCity => _currentCity;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Key untuk SharedPreferences
  static const _kCachedCityKey = 'cached_city';
  static const _kLastUpdatedKey = 'last_updated';

  bool _isLocationFresh() {
    return _lastUpdated != null &&
        DateTime.now().difference(_lastUpdated!) < Duration(hours: 1);
  }

  Future<void> fetchLocation({bool forceRefresh = false}) async {
    // Jika lokasi masih fresh (< 1 jam) dan tidak memaksa refresh
    if (!forceRefresh && _isLocationFresh()) {
      return;
    }

    try {
      final position = await getCurrentPosition();
      _currentCity = await getCityNameFromOSM(
        position.latitude,
        position.longitude,
      );

      _lastUpdated = DateTime.now();
      notifyListeners();

      // Simpan ke local storage
      await _cacheLocation();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _cacheLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCachedCityKey, _currentCity ?? '');
      await prefs.setString(
        _kLastUpdatedKey,
        _lastUpdated?.toIso8601String() ?? '',
      );
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  Future<void> loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCity = prefs.getString(_kCachedCityKey);
      final lastUpdatedStr = prefs.getString(_kLastUpdatedKey);

      if (cachedCity != null && cachedCity.isNotEmpty) {
        _currentCity = cachedCity;
        _lastUpdated =
            lastUpdatedStr != null ? DateTime.parse(lastUpdatedStr) : null;
        notifyListeners();
      }
      print('Cached city: $_currentCity, Last updated: $_lastUpdated');
    } catch (e) {
      print('Error loading cached location: $e');
    }
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }

  Future<void> updateLocationToFirebase(
    Position position,
    String merchantId,
  ) async {
    final data = {
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await _dbRef.child("locations/$merchantId").set(data);
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  Future<void> deleteLocationFromFirebase(String merchantId) async {
    try {
      await _dbRef.child("locations/$merchantId").remove();
    } catch (e) {
      print("Error deleting location: $e");
    }
  }

  Stream<Map<String, LatLng>> getActiveLocations() {
    return _dbRef
        .child('locations')
        .orderByChild('timestamp')
        .startAt(
          DateTime.now().subtract(Duration(minutes: 30)).millisecondsSinceEpoch,
        )
        .onValue
        .map((event) {
          final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
          if (data == null) return {};

          return data.map(
            (userId, locData) =>
                MapEntry(userId, LatLng(locData['lat'], locData['lng'])),
          );
        });
  }

  Stream<List<Merchant>> getLiveMerchants() {
    return _dbRef
        .child("locations")
        .orderByChild('timestamp')
        .startAt(
          DateTime.now().subtract(Duration(minutes: 30)).millisecondsSinceEpoch,
        )
        .onValue
        .asyncMap((event) async {
          final locationData = event.snapshot.value as Map?;
          if (locationData == null) return [];

          final List<Merchant> merchants = [];

          for (final entry in locationData.entries) {
            final merchantId = entry.key as String;
            final locData = entry.value as Map;
            try {
              final doc =
                  await _firestore
                      .collection('merchants')
                      .doc(merchantId)
                      .get();

              if (doc.exists) {
                final merchantData = doc.data() as Map<String, dynamic>;
                final profileDoc =
                    await _firestore.collection('users').doc(merchantId).get();
                final profileData = profileDoc.data() as Map<String, dynamic>;
                // Gabungkan data lokasi dengan data merchant
                merchantData.addAll({
                  'id': merchantId,
                  'photoUrl': profileData['photoUrl'],
                  'name': profileData['name'],
                  'lat': locData['lat'],
                  'lng': locData['lng'],
                  // 'timestamp': locData['timestamp'],
                });
                merchants.add(Merchant.fromMap(merchantData));
              }
            } catch (e) {
              print('Error fetching merchant $merchantId: $e');
            }
          }
          print('Fetched ${merchants.length} merchants');
          return merchants;
        });
  }

  Future<double> getRouteDistance(LatLng start, LatLng end) async {
    final String osrmBaseUrl = 'https://router.project-osrm.org/route/v1';
    final String url =
        '$osrmBaseUrl/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['routes'][0]['distance'] / 1000)
            .toDouble(); // Convert to km
      }
    } catch (e) {
      print('Error calculating route: $e');
    }
    return 0.0;
  }

  Future<String> getCityNameFromOSM(double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city = data['address']['city'] ?? '';
        // Hapus karakter non-ASCII
        city = city.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
        return city.trim();
      }
    } catch (e) {
      print('Error: $e');
    }

    return '';
  }
}
