import 'dart:async';

import 'package:autotelematic_new_app/cubit/get_device_live_tracking_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_live_tracking_state.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/repository/get_device_live_tracking_repository.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/view/customreportandhistory.dart';
import 'package:autotelematic_new_app/view/devicecommands.dart';
import 'package:autotelematic_new_app/widgets/circular_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../utils/animated_marker.dart';

class VehicleTrackingOnMapScreen extends StatefulWidget {
  final int deviceID;
  final int deviceID1;

  const VehicleTrackingOnMapScreen({
    super.key,
    required this.deviceID,
    required this.deviceID1,
  });

  @override
  State<VehicleTrackingOnMapScreen> createState() =>
      _VehicleTrackingOnMapScreenState();
}

class _VehicleTrackingOnMapScreenState extends State<VehicleTrackingOnMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _controller;
  final animationController = Completer<GoogleMapController>();
  late GetDeviceLiveTrackingCubit vehicletrackingCubit;
  late Timer timer;
  bool isMapLoaded = false;
  double currentZoom = 15;
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  final List<Marker> animationMarkers = [];
  MarkerId kMarkerId = const MarkerId('MarkerId1');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.sp),
    boxShadow: [
      BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 5,
          offset: Offset(2, 2))
    ],
  );

  void animateCameraToLocation(LatLng targetLocation, double zoom) async {
    if (_controller != null && isMapLoaded && mounted) {
      try {
        CameraPosition cameraPosition =
            CameraPosition(target: targetLocation, zoom: zoom);
        await _controller!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } catch (e) {
        // Optionally log or ignore; map might be disposed or busy
      }
    }
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  Future<void> showDatePickerDialog(
      BuildContext context, String route, String deviceName, int deviceID) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomeHistoryDateTimePicker(deviceName, deviceID, route)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeviceCommandsPicker(int deviceID) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DeviceCommandsScreen(deviceID: deviceID),
      ),
    );
  }

  PopupMenuButton buildPopupMenuButton(
      String route, String imagePath, int deviceID, String label) {
    return PopupMenuButton<int>(
      color: Colors.white,
      position: PopupMenuPosition.under,
      onSelected: (value) {
        final dt = DateTime.now();
        final newFormat = DateFormat("yy-MM-dd");
        String toDate = newFormat.format(dt);
        String fromDate = toDate;
        String fromTime = '00:00:00';
        String toTime = '23:59:59';
        switch (value) {
          case 0:
            // Today
            break;
          case 1:
            fromDate = newFormat.format(dt.subtract(const Duration(days: 1)));
            toDate = fromDate;
            break;
          case 7:
            fromDate = newFormat.format(dt.subtract(const Duration(days: 6)));
            break;
          case 2:
            showDatePickerDialog(
              context,
              route == RoutesName.viewHistory ? 'playroutonmap' : 'reporttype',
              vehicletrackingCubit.deviceName,
              deviceID,
            );
            return;
        }
        Navigator.pushNamed(context, route,
            arguments: DeviceDataForReportsAndHistory(
              deviceId: deviceID,
              deviceTitle: vehicletrackingCubit.deviceName,
              fromDate: fromDate,
              toDate: toDate,
              fromTime: fromTime,
              toTime: toTime,
            ));
      },
      padding: EdgeInsets.zero,
      icon: CircularImageWidget(
        imagePath: imagePath,
        imageSize: 5.h,
        containerSize: 4.h,
        containerColor: Colors.white,
        borderColor: const Color(0xFF1976D2),
        borderWidth: 2.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 0, child: Text('Today')),
        PopupMenuItem(value: 1, child: Text('Yesterday')),
        PopupMenuItem(value: 7, child: Text('Last 7 Days')),
        PopupMenuItem(value: 2, child: Text('Custom Date')),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    vehicletrackingCubit = GetDeviceLiveTrackingCubit(
      repository: GetDeviceLiveTrackingRepository(),
    );
    vehicletrackingCubit.fetchDeviceLiveTracking(
        deviceId: widget.deviceID, dialogContext: context);

    timer = Timer.periodic(const Duration(seconds: 8), (_) {
      vehicletrackingCubit.fetchDeviceLiveTracking(
          deviceId: widget.deviceID, isRefresh: true, dialogContext: context);
    });
  }

  @override
  void dispose() {
    if (!vehicletrackingCubit.isClosed) {
      vehicletrackingCubit.close();
    }
    timer.cancel();
    _controller?.dispose();
    super.dispose();
  }

  late Marker marker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: LayoutBuilder(
        builder: (context, constraints) {
          final drawerHeight = MediaQuery.of(context).size.height * 0.34;
          final textSize = drawerHeight * 0.0245;
          final paddingSize = drawerHeight * 0.05;

          return SizedBox(
            height: drawerHeight,
            child: Drawer(
              width: 18.w,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: paddingSize),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDrawerItem(
                    imagePath: 'assets/images/TimeMachine_50px.png',
                    label: 'History',
                    paddingSize: paddingSize,
                    textSize: textSize * 1.5,
                    isPopup: true,
                    popupMenu: buildPopupMenuButton(
                        RoutesName.viewHistory,
                        'assets/images/TimeMachine_50px.png',
                        widget.deviceID1,
                        'History'),
                  ),
                  Column(
                    children: [
                      PopupMenuButton(
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        icon: CircularImageWidget(
                          imagePath: "assets/images/ComboChart_48px.png",
                          imageSize: 6.h,
                          containerSize: 4.5.h,
                          containerColor: Colors.white,
                          borderColor: const Color(0xFF1976D2),
                          borderWidth: 2.5,
                        ),
                        onSelected: (value) {
                          final dt = DateTime.now().toLocal();
                          final dateFormat = DateFormat("yyyy-MM-dd");
                          String toDate = dateFormat.format(dt);
                          String fromDate = toDate;
                          String fromTime = '00:00:00';
                          String toTime = '23:59:59';
                          switch (value) {
                            case 0:
                              // Today
                              break;
                            case 1:
                              fromDate = dateFormat
                                  .format(dt.subtract(const Duration(days: 1)));
                              toDate = fromDate;
                              break;
                            case 7:
                              fromDate = dateFormat
                                  .format(dt.subtract(const Duration(days: 6)));
                              break;
                            case 2:
                              showDatePickerDialog(
                                  context,
                                  'reporttype',
                                  vehicletrackingCubit.deviceName,
                                  widget.deviceID1);
                              return;
                          }
                          Navigator.pushNamed(
                            context,
                            RoutesName.reportTypes,
                            arguments: DeviceDataForReportsAndHistory(
                                deviceId: widget.deviceID1,
                                deviceTitle: vehicletrackingCubit.deviceName,
                                fromDate: fromDate,
                                toDate: toDate,
                                fromTime: fromTime,
                                toTime: toTime),
                          );
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 0, child: Text('Today')),
                          PopupMenuItem(value: 1, child: Text('Yesterday')),
                          PopupMenuItem(value: 7, child: Text('7 Days')),
                          PopupMenuItem(value: 2, child: Text('Custom Date')),
                        ],
                      ),
                      Text(
                        "Reports",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: textSize * 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  InkWell(
                    onTap: () => showDeviceCommandsPicker(widget.deviceID1),
                    child: _buildDrawerItem(
                      imagePath: 'assets/images/Lock_48px.png',
                      label: 'Immobilizer',
                      paddingSize: paddingSize,
                      textSize: textSize * 1.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.vehicleSensorData,
                          arguments: {
                            'vehicleSensorsData': vehicletrackingCubit.sensors,
                            'vehicleName':
                                vehicletrackingCubit.deviceName.toString() ??
                                    'Unknown',
                          });
                    },
                    child: _buildDrawerItem(
                      imagePath: 'assets/images/Pressure_40px.png',
                      label: 'Sensors',
                      paddingSize: paddingSize,
                      textSize: textSize * 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [Text("")],
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Icon(Icons.arrow_back_ios_new_outlined,
                size: 2.4.h, color: Color(0xFF212121)),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Live Tracking',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              color: Color(0xFF212121)),
        ),
      ),
      body: BlocProvider(
        create: (context) => vehicletrackingCubit,
        child:
            BlocBuilder<GetDeviceLiveTrackingCubit, GetDeviceLiveTrackingState>(
          builder: (context, state) {
            if (state is GetDeviceLiveTrackingLoading && state.showLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.loadingImage,
                    const SizedBox(height: 5),
                    const Text('Loading...')
                  ],
                ),
              );
            }

            if (state is GetDeviceLiveTrackingError && state.model == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.loadingImage,
                    const SizedBox(height: 5),
                    Text(state.errorMessage ?? 'Error loading data')
                  ],
                ),
              );
            }

// Build marker only when valid data is available
            if (vehicletrackingCubit.deviceLat != 0.0 &&
                vehicletrackingCubit.deviceLng != 0.0) {
              marker = Marker(
                markerId: MarkerId(widget.deviceID.toString()),
                position: LatLng(vehicletrackingCubit.deviceLat,
                    vehicletrackingCubit.deviceLng),
                anchor: const Offset(0.5, 0.5),
                rotation: vehicletrackingCubit.deviceRotation,
                icon: vehicletrackingCubit.markerImage,
              );
              animationMarkers
                ..clear()
                ..add(marker);
            } else {
              animationMarkers.clear();
            }

            if (state is GetDeviceLiveTrackingLoaded ||
                (state is GetDeviceLiveTrackingLoading && !state.showLoading) ||
                (state is GetDeviceLiveTrackingError && state.model != null)) {
// Trigger camera animation when map is loaded and valid coordinates are available
              if (isMapLoaded &&
                  vehicletrackingCubit.deviceLat != 0.0 &&
                  vehicletrackingCubit.deviceLng != 0.0) {
                animateCameraToLocation(
                    LatLng(vehicletrackingCubit.deviceLat,
                        vehicletrackingCubit.deviceLng),
                    currentZoom);
              }
              return Stack(
                children: [
                  vehicletrackingCubit.vehicleCurrentStatusFromAPI == 'online'
                      ? onlineState()
                      : otherThanOnlineState(),
                  _buildInfoCard(),
                  Positioned(
                    bottom: 13.h,
                    right: 7.w,
                    child: Container(
                      height: 130,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(vehicletrackingCubit.ignitionColor,
                                Colors.white, 0.9)!,
                            const Color.fromARGB(255, 255, 255, 255)
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      width: MediaQuery.sizeOf(context).width / 3,
                      child: SfRadialGauge(
                        axes: [
                          RadialAxis(
                            minimum: 0,
                            maximum: 150,
                            radiusFactor: 0.95,
                            interval: 20,
                            axisLineStyle: const AxisLineStyle(
                              thickness: 0.08,
                              thicknessUnit: GaugeSizeUnit.factor,
                            ),
                            majorTickStyle: const MajorTickStyle(
                                length: 8, thickness: 2, color: Colors.black54),
                            minorTickStyle: const MinorTickStyle(
                                length: 4, thickness: 1, color: Colors.black54),
                            showLabels: true,
                            axisLabelStyle: GaugeTextStyle(fontSize: 11.sp),
                            labelOffset: 10,
                            ranges: [
                              GaugeRange(
                                  startValue: 0,
                                  endValue: 50,
                                  color: Colors.green[400]),
                              GaugeRange(
                                  startValue: 50,
                                  endValue: 100,
                                  color: Colors.orange[400]),
                              GaugeRange(
                                  startValue: 100,
                                  endValue: 150,
                                  color: Colors.red[400]),
                            ],
                            pointers: [
                              NeedlePointer(
                                value:
                                    vehicletrackingCubit.deviceSpeed.toDouble(),
                                needleColor: Colors.black87,
                                needleStartWidth: 1,
                                needleEndWidth: 5,
                                needleLength: 0.5,
                                knobStyle: const KnobStyle(
                                  color: Colors.redAccent,
                                  borderWidth: 0.05,
                                  borderColor: Colors.black54,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  knobRadius: 0.08,
                                ),
                              ),
                            ],
                            annotations: [
                              GaugeAnnotation(
                                widget: Text(
                                  '${vehicletrackingCubit.deviceSpeed} km/h',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                angle: 90,
                                positionFactor: 0.8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7.h,
                    right: 3.w,
                    child: _buildControlButtons(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: .5.h, bottom: .5.h, left: 3.5.w, right: 3.5.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    decoration: _cardDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              vehicletrackingCubit.deviceName,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                          child: Transform.scale(
                            scale: 1.3,
                            child: SvgPicture.asset(
                              "assets/images/ignition.svg",
                              color: vehicletrackingCubit.ignitionColor,
                            ),
                          ),
                        ),
                        Text(
                          "${vehicletrackingCubit.totalDistance} KM",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.bold,
                            fontFamily: "Digital",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTheme.loadingImage,
                  const SizedBox(height: 5),
                  const Text('Initial state')
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget onlineState() {
    return AnimatedMarker(
      animatedMarkers: animationMarkers.toSet(),
      duration: const Duration(seconds: 15),
      fps: 20,
      curve: Curves.ease,
      builder: (context, animatedMarkers) {
        return vehicletrackingCubit.buildGoogleMap(
          markers: animatedMarkers,
          useAnimation: true,
          initialPosition: CameraPosition(
            target: LatLng(
                vehicletrackingCubit.deviceLat, vehicletrackingCubit.deviceLng),
            zoom: currentZoom,
          ),
          onCameraMove: currentMapStatus,
          onMapCreated: (gController) {
            _controller = gController;
            if (!animationController.isCompleted) {
              animationController.complete(gController);
            }
            isMapLoaded = true;
            if (vehicletrackingCubit.deviceLat != 0.0 &&
                vehicletrackingCubit.deviceLng != 0.0) {
// animateCameraToLocation(
// LatLng(vehicletrackingCubit.deviceLat,
// vehicletrackingCubit.deviceLng),
// currentZoom,
// );
            }
          },
          padding:
              const EdgeInsets.only(bottom: 200, right: 7, left: 15, top: 15),
        );
      },
    );
  }

  Widget otherThanOnlineState() {
    return vehicletrackingCubit.buildGoogleMap(
      markers: animationMarkers.toSet(),
      useAnimation: false,
      initialPosition: CameraPosition(
        target: LatLng(
            vehicletrackingCubit.deviceLat, vehicletrackingCubit.deviceLng),
        zoom: currentZoom,
      ),
      onCameraMove: currentMapStatus,
      onMapCreated: (gController) {
        _controller = gController;
        isMapLoaded = true;
      },
      padding: const EdgeInsets.only(bottom: 150, right: 7),
    );
  }

  Widget _buildInfoCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
        margin: EdgeInsets.only(bottom: 2.5.h, left: 2.5.w, right: 2.5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                  vehicletrackingCubit.ignitionColor, Colors.white, 0.8)!,
              const Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.webhook_outlined,
              vehicletrackingCubit.vehicleCurrentStatusFromAPI == 'ack'
                  ? '${vehicletrackingCubit.vehicleStatusText} since ${vehicletrackingCubit.deviceStopDuration}'
                  : vehicletrackingCubit.vehicleStatusText,
            ),
            _buildInfoRow(
                Icons.update, vehicletrackingCubit.deviceLatestUpdate),
            _buildInfoRow(
              Icons.pin_drop_outlined,
              vehicletrackingCubit.deviceAddress.isNotEmpty
                  ? vehicletrackingCubit.deviceAddress
                  : 'Unknown Address',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String? text, {Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: child ??
                Text(
                  text ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlButton(
              icon: Icons.map,
              onPressed: () {
                vehicletrackingCubit.toggleMapType();
              },
            ),
            _buildControlButton(
              icon: Icons.traffic,
              onPressed: () {
                vehicletrackingCubit.toggleTraffic();
              },
            ),
            _buildControlButton(
              icon: Icons.streetview,
              onPressed: () => MapsLauncher.launchCoordinates(
                  vehicletrackingCubit.deviceLat,
                  vehicletrackingCubit.deviceLng),
            ),
// _buildControlButton(
// icon: Icons.share,
// onPressed: () => Share.share(
// 'https://www.google.com/maps/search/?api=1&map_action=pano&query=${vehicletrackingCubit.deviceLat},${vehicletrackingCubit.deviceLng}'),
// ),
            _buildControlButton(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.green,
              onPressed: () {
                if (_scaffoldKey.currentState != null &&
                    !_scaffoldKey.currentState!.isEndDrawerOpen) {
                  _scaffoldKey.currentState!.openEndDrawer();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      Color? backgroundColor,
      Color? iconColor,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor ?? Colors.black54, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String imagePath,
    required String label,
    double imageSize = 30,
    required double paddingSize,
    required double textSize,
    bool isPopup = false,
    PopupMenuButton? popupMenu,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingSize),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isPopup
              ? popupMenu!
              : CircularImageWidget(
                  imagePath: imagePath,
                  imageSize: imageSize,
                  containerSize: imageSize * 0.75,
                  containerColor: Colors.white,
                  borderColor: const Color(0xFF1976D2),
                  borderWidth: 2.5,
                ),
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: textSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
