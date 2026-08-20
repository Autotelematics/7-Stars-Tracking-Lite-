import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(LatLng pos1, LatLng pos2) {
  const double R = 6371e3;
  double lat1 = pos1.latitude * pi / 180;
  double lat2 = pos2.latitude * pi / 180;
  double deltaLat = (pos2.latitude - pos1.latitude) * pi / 180;
  double deltaLng = (pos2.longitude - pos1.longitude) * pi / 180;

  double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
      cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}