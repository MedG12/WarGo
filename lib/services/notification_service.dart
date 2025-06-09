import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargo/models/merchant.dart';

class ProximityAlertService {
  DateTime? _lastProximityCheck;
  static const _prefsKey = 'tagged_merchants';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(initSettings);

    _isInitialized = true;
  }

  Future<void> addTaggedMerchant(String merchantId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getTaggedMerchants();
    final updated = [...existing, merchantId];

    await prefs.setString(_prefsKey, jsonEncode(updated));
  }

  Future<List<String>> getTaggedMerchants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey) ?? '[]';
    return List<String>.from(jsonDecode(jsonStr));
  }

  Future<void> removeTaggedMerchant(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getTaggedMerchants();
    final updated = existing.where((e) => e != id).toList();

    await prefs.setString(_prefsKey, jsonEncode(updated));
  }

  void checkProximity(
    List<Merchant> merchantsData,
    Position userPosition,
  ) async {
    final now = DateTime.now();

    // Batasi hanya satu notifikasi per X detik (misalnya 10 detik)
    if (_lastProximityCheck != null &&
        now.difference(_lastProximityCheck!) < const Duration(seconds: 10)) {
      return;
    }

    _lastProximityCheck = now;
    await init();
    final taggedMerchants = await getTaggedMerchants();
    print(taggedMerchants);

    for (final merchant in merchantsData) {
      if (!taggedMerchants.contains(merchant.id)) continue;
      final distance = await Geolocator.distanceBetween(
        merchant.location!.latitude,
        merchant.location!.longitude,
        userPosition.latitude,
        userPosition.longitude,
      );
      if (distance < 30) {
        _sendNotification(
          title: "Yang ditunggu tunggu sudah datang!",
          body: "${merchant.name} sedang berada di dekat kamu",
        );
        removeTaggedMerchant(merchant.id);
      }
    }
  }

  Future<void> _sendNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'proximity_channel',
      'Proximity Alerts',
      channelDescription: 'Pemberitahuan saat dekat merchant',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      Random().nextInt(100000),
      title,
      body,
      notificationDetails,
    );
  }
}
