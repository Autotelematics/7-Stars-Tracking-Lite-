import 'package:autotelematic_new_app/model/playbackroutemodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripsRoutModel {
  dynamic status;
  int? routIndex;
  String? tripStart;
  String? rawTime;
  String? tripEnd;
  dynamic distance;
  dynamic topSpeed;
  dynamic avgSpeed;
  String? totalTripDuration;
  List<PlayBackRoute> tripPlayBackRout = [];
  List<LatLng> tripRoutLatLng = [];
}
