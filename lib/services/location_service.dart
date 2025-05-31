import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  String? _currentCity;
  DateTime? _lastUpdated;

  String? get currentCity => _currentCity;

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
