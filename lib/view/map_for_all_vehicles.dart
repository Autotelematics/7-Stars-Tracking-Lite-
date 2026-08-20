import 'package:autotelematic_new_app/cubit/get_device_status_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_status_state.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapForAllVehiclesScreen extends StatefulWidget {
  const MapForAllVehiclesScreen({super.key});

  @override
  State<MapForAllVehiclesScreen> createState() =>
      _MapForAllVehiclesScreenState();
}

class _MapForAllVehiclesScreenState extends State<MapForAllVehiclesScreen> {
  GoogleMapController? _controller;
  Set<Marker> _currentMarkers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetDeviceStatusCubit>().prepareMarkersForMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GetDeviceStatusCubit>();

    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<GetDeviceStatusCubit, GetDeviceStatusState>(
          listener: (context, state) {
            if (state is GetDeviceStatusLoaded) {
              setState(() {
                _currentMarkers = cubit.deviceMarkersList;
              });
            }
            if (state is GetDeviceStatusNavigate) {
              if (state.deviceId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid device ID')),
                );
                return;
              }
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushNamed(
                  context,
                  RoutesName.vehicleLiveTracking,
                  arguments: {
                    'groupID': 0,
                    'deviceID': state.deviceId,
                    'homeCubit': cubit,
                    'deviceID1': state.deviceId,
                  },
                );
              });
            }
          },
          builder: (context, state) {
            // Stack allows overlays above the map
            return Stack(
              children: [
                // Always build the map, but overlay loader if loading.
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(30.229696, 69.982138),
                    zoom: 5,
                  ),
                  mapType: cubit.currentMapType,
                  trafficEnabled: cubit.enableTraffic,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: false,
                  markers: _currentMarkers,
                  onMapCreated: (controller) {
                    _controller = controller;
                    cubit.setMapController(controller);
                  },
                ),
                // Cover the map with loader if loading or markers not ready
                if (state.isLoading && state.showLoading ||
                    _currentMarkers.isEmpty)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTheme.loadingImage,
                          const SizedBox(height: 8),
                          const Text('Loading devices...'),
                        ],
                      ),
                    ),
                  ),

                // --- Error overlay ---
                if (state is GetDeviceStatusError)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 40, color: Colors.red),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              cubit.fetchDeviceStatus(
                                  isRefresh: true, context: context);
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- Empty overlay ---
                if (_currentMarkers.isEmpty &&
                    state is GetDeviceStatusLoaded &&
                    state.model == null)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No devices found."),
                          ElevatedButton(
                            onPressed: () {
                              cubit.fetchDeviceStatus(
                                  isRefresh: true, context: context);
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- Floating action buttons (always visible above map) ---
                Positioned(
                  right: 10,
                  top: 150,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        heroTag: 'map_type_button',
                        onPressed: () {
                          context.read<GetDeviceStatusCubit>().toggleMapType();
                        },
                        tooltip: 'Toggle Map Type',
                        child: const Icon(Icons.map, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor:
                        context.watch<GetDeviceStatusCubit>().enableTraffic
                            ? Colors.green
                            : Colors.white,
                        heroTag: 'traffic_button',
                        onPressed: () {
                          context.read<GetDeviceStatusCubit>().toggleTraffic();
                        },
                        tooltip: 'Toggle Traffic',
                        child: const Icon(Icons.traffic, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        heroTag: 'marker_toggle_button',
                        onPressed: () {
                          context
                              .read<GetDeviceStatusCubit>()
                              .toggleMarkerLabels();
                        },
                        tooltip: context
                            .watch<GetDeviceStatusCubit>()
                            .showMarkerLabels
                            ? 'Hide Labels'
                            : 'Show Labels',
                        child: Icon(
                          context.watch<GetDeviceStatusCubit>().showMarkerLabels
                              ? Icons.label_outline
                              : Icons.label_off_outlined,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
