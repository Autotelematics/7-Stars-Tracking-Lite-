import 'dart:async';
import 'dart:math';

import 'package:autotelematic_new_app/model/get_device_live_tracking_model.dart';
import 'package:autotelematic_new_app/repository/get_device_live_tracking_repository.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/helper/map_marker_design.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'get_device_live_tracking_state.dart';

class GetDeviceLiveTrackingCubit extends Cubit<GetDeviceLiveTrackingState> {
  GetDeviceLiveTrackingCubit({required this.repository})
      : super(GetDeviceLiveTrackingLoading(showLoading: true));

  final GetDeviceLiveTrackingRepository repository;

  BitmapDescriptor markerImage = BitmapDescriptor.defaultMarker;
  GetDeviceLiveTrackingModel? deviceDataModal;
  double deviceLat = 0.0;
  double deviceLng = 0.0;
  double deviceRotation = 0.0;
  String deviceName = '';
  String totalDistance = '0';
  String vehicleCurrentStatusFromAPI = '';
  String deviceStopDuration = '0';
  int deviceSpeed = 0;
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  String deviceLatestUpdate = '';
  String deviceAddress = '';
  List<Sensor>? sensors;
  bool isInitial = true;
  final Set<Polyline> routPolyLine = {};
  final Set<Circle> routCirclesLine = {};
  DateTime? _lastPacketTime;

  Color get ignitionColor {
    final statusLower = vehicleCurrentStatusFromAPI.toLowerCase();
    if (statusLower == "online") return Colors.green;
    if (statusLower == "ack") return Colors.red;
    if (statusLower == "engine") return Colors.green;
    return Colors.blue;
  }

  String get vehicleStatusText {
    switch (vehicleCurrentStatusFromAPI) {
      case 'online':
        return 'Running';
      case 'ack':
        return 'Stopped';
      case 'engine':
        return 'Idle';
      case 'offline':
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  String formatDuration(int seconds) {
    if (seconds < 60) return "$seconds sec";
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    if (minutes < 60) {
      return seconds > 0 ? "$minutes min $seconds sec" : "$minutes min";
    }
    int hours = minutes ~/ 60;
    minutes = minutes % 60;
    if (hours < 24) {
      String hr = "$hours hr";
      String min = minutes > 0 ? " $minutes min" : "";
      return seconds > 0
          ? "$hr$min $seconds sec"
          : min.isNotEmpty
          ? "$hr$min"
          : hr;
    }
    int days = hours ~/ 24;
    hours = hours % 24;
    String d = "$days d";
    String h = hours > 0 ? " $hours h" : "";
    String m = minutes > 0 ? " $minutes m" : "";
    return seconds > 0
        ? "$d$h$m $seconds s"
        : m.isNotEmpty
        ? "$d$h$m"
        : h.isNotEmpty
        ? "$d$h"
        : d;
  }

  double calculateBearing(LatLng start, LatLng end) {
    double startLat = radians(start.latitude);
    double startLng = radians(start.longitude);
    double endLat = radians(end.latitude);
    double endLng = radians(end.longitude);

    double dLng = endLng - startLng;

    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    double bearing = atan2(y, x);
    return (degrees(bearing) + 360) % 360;
  }

  double radians(double degrees) => degrees * pi / 180;
  double degrees(double radians) => radians * 180 / pi;

  static double _safeDouble(dynamic val, {double defaultValue = 0.0}) {
    try {
      if (val == null ||
          val.toString().trim().isEmpty ||
          val.toString() == '-' ||
          val.toString() == 'null') {
        if (kDebugMode) {
          print('Invalid double value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing double: $val, error: $e, returning $defaultValue');
      }
      return defaultValue;
    }
  }

  static int _safeInt(dynamic val, {int defaultValue = 0}) {
    try {
      if (val == null ||
          val.toString().trim().isEmpty ||
          val.toString() == '-' ||
          val.toString() == 'null') {
        if (kDebugMode) {
          print('Invalid int value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is int) return val;
      return int.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing int: $val, error: $e, returning $defaultValue');
      }
      return defaultValue;
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double lat1 = radians(start.latitude);
    double lng1 = radians(start.longitude);
    double lat2 = radians(end.latitude);
    double lng2 = radians(end.longitude);

    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }


  double _resolveOdometerValue() {
    final sensorsList = deviceDataModal?.item?.sensors;
    if (sensorsList != null) {
      final virtualOdometerSensor = sensorsList.firstWhere(
            (s) =>
        s.type?.toLowerCase() == 'odometer' &&
            (s.name?.toLowerCase().contains('virtual odometer') ?? false),
        orElse: () => Sensor(),
      );
      if (virtualOdometerSensor.id != null) {
        return _safeDouble(virtualOdometerSensor.val, defaultValue: 0.0);
      }
    }
    return _safeDouble(deviceDataModal?.item?.odometer, defaultValue: 0.0);
  }

  Future<void> setDeviceMarkerAndPolyLines() async {
    if (deviceDataModal?.item == null) {
      if (kDebugMode) {
        print('No device data available for marker and polylines');
      }
      return;
    }

    try {
      markerImage = await MapMarkerMaker.getMarkerIcon(
        ApiEndpointUrls.baseImgURL + (deviceDataModal!.item!.path ?? ''),
        deviceName,
        Colors.red,
        deviceRotation,
        false,
      );

      List<LatLng> polyPoints = [];
      if (deviceDataModal!.item!.tail != null &&
          deviceDataModal!.item!.tail!.isNotEmpty) {
        for (var tail in deviceDataModal!.item!.tail!) {
          double lat = _safeDouble(tail.lat);
          double lng = _safeDouble(tail.lng);
          if (lat != 0.0 && lng != 0.0) {
            polyPoints.add(LatLng(lat, lng));
          } else {
            if (kDebugMode) print('Invalid tail point: lat=$lat, lng=$lng');
          }
        }
      }

      if (polyPoints.isNotEmpty) {
        // Polyline/circle logic commented out intentionally
      } else {
        if (kDebugMode) print('No valid polyline points available');
      }
    } catch (e) {
      if (kDebugMode) print('Error in setDeviceMarkerAndPolyLines: $e');
    }
  }

  GoogleMap buildGoogleMap({
    required Set<Marker> markers,
    bool useAnimation = false,
    required CameraPosition initialPosition,
    required Function(CameraPosition) onCameraMove,
    required Function(GoogleMapController) onMapCreated,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GoogleMap(
      buildingsEnabled: false,
      indoorViewEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: true,
      minMaxZoomPreference: const MinMaxZoomPreference(1, 25),
      mapType: currentMapType,
      trafficEnabled: enableTraffic,
      myLocationButtonEnabled: false,
      markers: markers,
      zoomControlsEnabled: false,
      polylines: routPolyLine,
      circles: routCirclesLine,
      initialCameraPosition: initialPosition,
      onCameraMove: onCameraMove,
      onMapCreated: onMapCreated,
      padding: padding,
    );
  }

  void toggleMapType() {
    currentMapType =
    currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    if (kDebugMode) {
      print('Toggled map type to: $currentMapType');
    }
    refreshVehicleTrackingCubit();
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    if (kDebugMode) {
      print('Toggled traffic to: $enableTraffic');
    }
    refreshVehicleTrackingCubit();
  }

  Future<void> fetchDeviceLiveTracking(
      {required int deviceId,
        bool isRefresh = false,
        required BuildContext dialogContext}) async {
    try {
      if (!isRefresh) {
        emit(GetDeviceLiveTrackingLoading(showLoading: true));
      }

      String? userApiHashKey = await UserSessions.getUserApiHash();

      final response = await repository.getDeviceLiveTrackingApi(
          deviceId: deviceId, dialogContext: dialogContext);
      deviceDataModal = response;
      if (deviceDataModal?.item == null) {
        emit(GetDeviceLiveTrackingError(errorMessage: 'No device data found'));
        return;
      }

      // Validate and assign data
      deviceName = deviceDataModal!.item!.name ?? 'Unknown';
      totalDistance = _resolveOdometerValue().toStringAsFixed(2);

      vehicleCurrentStatusFromAPI =
          deviceDataModal!.item!.online?.toLowerCase() ?? 'offline';
      deviceStopDuration =
          _safeInt(deviceDataModal!.item!.stopDuration, defaultValue: 0)
              .toString();
      deviceSpeed = _safeInt(deviceDataModal!.item!.speed, defaultValue: 0);
      deviceLatestUpdate = deviceDataModal!.item!.time ?? '';
      deviceAddress = deviceDataModal!.item!.addr ?? 'Unknown';
      sensors = deviceDataModal?.item?.sensors;

      String? deviceTimeStr = deviceDataModal!.item!.time;
      DateTime? deviceTime;
      try {
        deviceTime = deviceTimeStr!.isNotEmpty
            ? DateFormat("dd-MM-yyyy hh:mm:ss a").parse(deviceTimeStr)
            : null;
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing device time: $deviceTimeStr, error: $e');
        }
        deviceTime = null;
      }
      DateTime now = DateTime.now();
      bool skipInitialAnimation = false;
      if (deviceTime == null || now.difference(deviceTime).inMinutes > 5) {
        skipInitialAnimation = true;
      }

      _lastPacketTime = deviceTime ?? now;

      if (isInitial &&
          !skipInitialAnimation &&
          vehicleCurrentStatusFromAPI == 'online') {
        await _handleInitialAnimation();
      } else {
        await _updateDeviceData(isRefresh: isRefresh);
      }

      isInitial = false;
      if (!isClosed) {
        emit(GetDeviceLiveTrackingLoaded());
      }
    } catch (e) {
      if (kDebugMode) print('Error in fetchDeviceLiveTracking: $e');
      emit(GetDeviceLiveTrackingError(
          errorMessage: 'Failed to load data: ${e.toString()}'));
    }
  }

  Future<void> _handleInitialAnimation() async {
    if (deviceDataModal?.item == null) {
      if (kDebugMode) print('No device data for initial animation');
      return;
    }

    double liveLat = _safeDouble(deviceDataModal!.item!.lat);
    double liveLng = _safeDouble(deviceDataModal!.item!.lng);
    double course = _safeDouble(deviceDataModal!.item!.course);
    int speed = _safeInt(deviceDataModal!.item!.speed);
    var tailList = deviceDataModal!.item!.tail;

    if (tailList != null &&
        tailList.length >= 2 &&
        liveLat != 0.0 &&
        liveLng != 0.0 &&
        course != 0.0 &&
        speed != 0) {
      var secondLastTail = tailList[tailList.length - 2];
      var lastTail = tailList.last;
      double lat1 = _safeDouble(secondLastTail.lat);
      double lng1 = _safeDouble(secondLastTail.lng);
      double lat2 = _safeDouble(lastTail.lat);
      double lng2 = _safeDouble(lastTail.lng);

      if (lat1 != 0.0 && lng1 != 0.0 && lat2 != 0.0 && lng2 != 0.0) {
        double tailBearing =
        calculateBearing(LatLng(lat1, lng1), LatLng(lat2, lng2));

        deviceLat = lat1;
        deviceLng = lng1;
        deviceRotation = tailBearing;
        deviceSpeed = speed;
        await setDeviceMarkerAndPolyLines();
        if (!isClosed) {
          emit(GetDeviceLiveTrackingLoaded());
        }

        const int steps = 10;
        const int durationMs = 400;
        const int stepDurationMs = durationMs ~/ steps;

        for (int i = 1; i <= steps; i++) {
          await Future.delayed(Duration(milliseconds: stepDurationMs));
          double t = i / steps;
          deviceLat = lat1 + (lat2 - lat1) * t;
          deviceLng = lng1 + (lng2 - lng1) * t;
          deviceRotation = tailBearing;
          await setDeviceMarkerAndPolyLines();
          if (!isClosed) {
            emit(GetDeviceLiveTrackingLoaded());
          }
        }

        if (lat2 != liveLat || lng2 != liveLng) {
          for (int i = 1; i <= steps; i++) {
            await Future.delayed(
                Duration(milliseconds: durationMs + stepDurationMs * i));
            double t = i / steps;
            deviceLat = lat2 + (liveLat - lat2) * t;
            deviceLng = lng2 + (liveLng - liveLng) * t;
            deviceRotation = course;
            await setDeviceMarkerAndPolyLines();
            if (!isClosed) {
              emit(GetDeviceLiveTrackingLoaded());
            }
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Invalid tail coordinates: lat1=$lat1, lng1=$lng1, lat2=$lat2, lng2=$lng2');
        }
        await _updateDeviceData(isRefresh: false);
      }
    } else {
      if (kDebugMode) {
        print(
            'Invalid data for animation: tailList=$tailList, liveLat=$liveLat, liveLng=$liveLng, course=$course, speed=$speed');
      }
      await _updateDeviceData(isRefresh: false);
    }
  }

  Future<void> _updateDeviceData({required bool isRefresh}) async {
    if (deviceDataModal?.item == null) {
      if (kDebugMode) print('No device data for update');
      return;
    }

    double lat = _safeDouble(deviceDataModal!.item!.lat);
    double lng = _safeDouble(deviceDataModal!.item!.lng);
    double course = _safeDouble(deviceDataModal!.item!.course);
    int speed = _safeInt(deviceDataModal!.item!.speed);
    String? deviceTimeStr = deviceDataModal!.item!.time;
    DateTime? deviceTime;
    try {
      deviceTime = deviceTimeStr!.isNotEmpty
          ? DateFormat("dd-MM-yyyy hh:mm:ss a").parse(deviceTimeStr)
          : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing device time: $deviceTimeStr, error: $e');
      }
      deviceTime = null;
    }
    DateTime now = DateTime.now();
    deviceTime ??= now;

    if (lat == 0.0 || lng == 0.0) {
      if (kDebugMode) print('Invalid coordinates: lat=$lat, lng=$lng');
      emit(GetDeviceLiveTrackingError(
          errorMessage: 'Invalid coordinates received',
          model: deviceDataModal));
      return;
    }

    double distanceKm = 0.0;
    int timeDiffSeconds = 0;
    double calculatedSpeedKmh = 0.0;
    if (_lastPacketTime != null && deviceLat != 0.0 && deviceLng != 0.0) {
      distanceKm = _calculateDistance(
        LatLng(deviceLat, deviceLng),
        LatLng(lat, lng),
      );
      timeDiffSeconds = deviceTime.difference(_lastPacketTime!).inSeconds;
      if (timeDiffSeconds > 0) {
        calculatedSpeedKmh = (distanceKm / timeDiffSeconds) * 3600;
      }
      if (kDebugMode) {
        print('Distance between packets: ${distanceKm.toStringAsFixed(2)} km, '
            'Time difference: $timeDiffSeconds seconds, '
            'Calculated speed: ${calculatedSpeedKmh.toStringAsFixed(2)} km/h');
      }
    }

    _lastPacketTime = deviceTime;

    if (vehicleCurrentStatusFromAPI == 'online' && isRefresh) {
      int durationMs = 500;
      if (timeDiffSeconds > 0 && timeDiffSeconds <= 40) {
        durationMs = timeDiffSeconds * 1000;
      }
      const int steps = 20;
      final int stepDurationMs = durationMs ~/ steps;
      double startLat = deviceLat;
      double startLng = deviceLng;
      double startRotation = deviceRotation;

      for (int i = 1; i <= steps; i++) {
        await Future.delayed(Duration(milliseconds: stepDurationMs));
        double t = i / steps;
        deviceLat = startLat + (lat - startLat) * t;
        deviceLng = startLng + (lng - startLng) * t;
        deviceRotation = _interpolateRotation(startRotation, course, t);
        deviceSpeed = speed;
        await setDeviceMarkerAndPolyLines();
        if (!isClosed) {
          emit(GetDeviceLiveTrackingLoaded());
        }
      }
    } else {
      deviceLat = lat;
      deviceLng = lng;
      deviceRotation = course;
      deviceSpeed = speed;
      await setDeviceMarkerAndPolyLines();
      if (!isClosed) {
        emit(GetDeviceLiveTrackingLoaded());
      }
    }
  }

  double _interpolateRotation(double start, double end, double t) {
    double diff = (end - start) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (start + diff * t) % 360;
  }

  void refreshVehicleTrackingCubit() {
    if (!isClosed) emit(GetDeviceLiveTrackingLoaded());
  }
}