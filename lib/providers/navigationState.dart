import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // atau LatLng sesuai versi kamu

class NavigationState extends ChangeNotifier {
  int? goToIndex;
  LatLng? merchantLocation;

  void navigateTo(int index, {LatLng? location}) {
    goToIndex = index;
    merchantLocation = location;
    notifyListeners(); 
  }

  void reset() {
    goToIndex = null;
    merchantLocation = null;
    notifyListeners();
  }
}
