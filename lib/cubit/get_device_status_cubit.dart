import 'dart:async';

import 'package:autotelematic_new_app/cubit/get_device_status_state.dart';
import 'package:autotelematic_new_app/model/get_device_status_model.dart';
import 'package:autotelematic_new_app/repository/get_device_status_repository.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/helper/map_marker_design.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetDeviceStatusCubit extends Cubit<GetDeviceStatusState> with WidgetsBindingObserver {
  final GetDeviceStatusRepository repository;
  final BuildContext context;
  GetDeviceStatusModel? _lastValidModel;
  final Set<Marker> deviceMarkersList = {};
  Timer? _timer;
  bool showMarkerLabels = true;
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  GoogleMapController? _mapController;

  String? _lastTappedMarkerId;
  int _tapCount = 0;
  LatLng? _zoomPosition;
  bool _enableNewCameraPosition = true;

  // Cache for marker icons (with and without labels)
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  GetDeviceStatusCubit(this.repository, this.context)
      : super(GetDeviceStatusInitial()) {
    WidgetsBinding.instance.addObserver(this);
    startPeriodicUpdates(context: context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      stopPeriodicUpdates();
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) startPeriodicUpdates(context: context);
      });
    }
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void toggleMapType() {
    currentMapType =
    currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    emit(GetDeviceStatusLoaded(_lastValidModel));
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    emit(GetDeviceStatusLoaded(_lastValidModel));
  }

  void toggleMarkerLabels() {
    showMarkerLabels = !showMarkerLabels;
    if (_lastValidModel != null) {
      _updateMarkersInfoWindow(_lastValidModel!.items);
    }
    emit(GetDeviceStatusLoaded(_lastValidModel));
  }

  void handleMarkerTap(int deviceId, LatLng position) {
    if (_lastTappedMarkerId == deviceId.toString()) {
      _tapCount++;
    } else {
      _lastTappedMarkerId = deviceId.toString();
      _tapCount = 1;
    }

    if (_tapCount == 1) {
      _zoomPosition = position;
      _enableNewCameraPosition = true;
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: position, zoom: 15),
          ),
        );
      }
      emit(GetDeviceStatusLoaded(_lastValidModel));
    } else {
      _zoomPosition = null;
      _enableNewCameraPosition = false;
      emit(GetDeviceStatusNavigate(deviceId: deviceId, position: position));
      _tapCount = 0;
      _lastTappedMarkerId = null;
    }
  }

  LatLng? getZoomPosition() => _zoomPosition;

  void clearZoomPosition() => _zoomPosition = null;

  bool isNewCameraPositionEnabled() => _enableNewCameraPosition;

  void startPeriodicUpdates({required BuildContext context}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchDeviceStatus(isPeriodic: true, context: context);
    });
  }

  void stopPeriodicUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchDeviceStatus({
    bool isRefresh = false,
    bool isPeriodic = false,
    required BuildContext context,
  }) async {
    emit(GetDeviceStatusLoading(
      previousModel: _lastValidModel,
      showLoading: true,
    ));

    try {
      final data = await repository.getDeviceStatusApi(dialogContext: context);
      if (data != null && (data.totalCount > 0 || data.items.isNotEmpty)) {
        _lastValidModel = data;
        // No markers prepared here!
        emit(GetDeviceStatusLoaded(data));
      } else {
        deviceMarkersList.clear();
        emit(GetDeviceStatusLoaded(null));
      }
    } catch (e) {
      if (_lastValidModel != null) {
        return;
      }

      String userFriendlyMessage = e.toString();
      if (userFriendlyMessage.contains('unserialize()')) {
        userFriendlyMessage =
            'Server is synchronizing data. Please try again in a moment.';
      } else if (userFriendlyMessage.contains('Exception:')) {
        userFriendlyMessage =
            userFriendlyMessage.replaceAll('Exception:', '').trim();
      } else if (userFriendlyMessage.contains('SocketException') ||
          userFriendlyMessage.contains('ClientException')) {
        userFriendlyMessage =
            'No internet connection. Please check your network.';
      }

      emit(GetDeviceStatusError(userFriendlyMessage, _lastValidModel));
    }
  }

  Future<void> prepareMarkersForMap() async {
    if (_lastValidModel != null) {
      await _prepareMarkers(_lastValidModel!.items);
      emit(
          GetDeviceStatusLoaded(_lastValidModel)); // To refresh UI with markers
    }
  }

  Future<void> _prepareMarkers(List<Item> items) async {
    final seen = <String>{};
    deviceMarkersList.clear();

    final filteredItems = items.where((item) {
      final key = '${item.id}_${item.lat}_${item.lng}';
      if (item.lat == null || item.lng == null || seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();

    final markerIcons = await Future.wait(
      filteredItems.map((item) async {
        try {
          final iconUrl = ApiEndpointUrls.baseImgURL + item.icon;
          final statusColor = _getStatusColor(item.online);
          // if (kDebugMode) {
          //   print("Marker for ${item.name}: Status=${item.online}, Color=$statusColor");
          // }
          // Generate icons for both labeled and non-labeled states
          final labeledIcon = await _getCachedMarkerIcon(
            iconUrl,
            item.name,
            statusColor,
            item.course.toDouble(),
            true,
          );
          final nonLabeledIcon = await _getCachedMarkerIcon(
            iconUrl,
            item.name,
            statusColor,
            item.course.toDouble(),
            false,
          );

          return {
            'item': item,
            'labeledIcon': labeledIcon,
            'nonLabeledIcon': nonLabeledIcon,
            'statusColor': statusColor,
          };
        } catch (e) {
          // if (kDebugMode) {
          //   print("Error generating marker for ${item.name}: $e");
          // }
          return null;
        }
      }),
    );

    for (var data in markerIcons) {
      if (data != null) {
        final item = data['item'] as Item;
        final icon = showMarkerLabels
            ? data['labeledIcon'] as BitmapDescriptor
            : data['nonLabeledIcon'] as BitmapDescriptor;
        final markerId = item.id.toString();

        final marker = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(item.lat!, item.lng!),
          rotation: item.course.toDouble(),
          icon: icon,
          infoWindow: showMarkerLabels
              ? InfoWindow(
            title: item.name,
            snippet: "Speed: ${item.speed} km/h",
          )
              : const InfoWindow(),
          onTap: () {
            // if (kDebugMode) {
            //   print("🖱 Marker tapped: ${item.name}");
            // }
            handleMarkerTap(item.id, LatLng(item.lat!, item.lng!));
          },
        );

        deviceMarkersList.add(marker);
      }
    }
  }

  Future<void> _updateMarkersInfoWindow(List<Item> items) async {
    final newMarkers = <Marker>{};
    final seen = <String>{};

    for (var item in items) {
      final key = '${item.id}_${item.lat}_${item.lng}';
      if (item.lat == null || item.lng == null || seen.contains(key)) {
        continue;
      }
      seen.add(key);

      final markerId = item.id.toString();
      final existingMarker = deviceMarkersList.firstWhere(
            (marker) => marker.markerId.value == markerId,
        orElse: () => Marker(markerId: MarkerId(markerId)),
      );

      final iconUrl = ApiEndpointUrls.baseImgURL + item.icon;
      final statusColor = _getStatusColor(item.online);
      final icon = await _getCachedMarkerIcon(
        iconUrl,
        item.name,
        statusColor,
        item.course.toDouble(),
        showMarkerLabels,
      );

      final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(item.lat!, item.lng!),
        rotation: item.course.toDouble(),
        icon: icon,
        infoWindow: showMarkerLabels
            ? InfoWindow(
          title: item.name,
          snippet: "Speed: ${item.speed} km/h",
        )
            : const InfoWindow(),
        onTap: () {
          // if (kDebugMode) {
          //   print("🖱 Marker tapped: ${item.name}");
          // }
          handleMarkerTap(item.id, LatLng(item.lat!, item.lng!));
        },
      );

      newMarkers.add(marker);
    }

    deviceMarkersList
      ..clear()
      ..addAll(newMarkers);
  }

  Future<BitmapDescriptor> _getCachedMarkerIcon(
      String iconUrl,
      String name,
      Color statusColor,
      double rotation,
      bool showLabels,
      ) async {
    final cacheKey =
        '$iconUrl|${statusColor.value}|$showLabels|$name'; // <-- FIXED
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }
    final icon = await MapMarkerMaker.getMarkerIcon(
      iconUrl,
      name,
      statusColor,
      0, // always 0, apply rotation to marker not icon
      showLabels,
    );
    _markerIconCache[cacheKey] = icon;
    return icon;
  }

  Color _getStatusColor(Online status) {
    switch (status) {
      case Online.ONLINE:
        return const Color(0xFF00C853); // Green
      case Online.OFFLINE:
        return const Color(0xFFFF6D00); // Orange
      case Online.ACK:
        return const Color(0xFFFF0000);
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    stopPeriodicUpdates();
    _mapController?.dispose();
    return super.close();
  }
}
