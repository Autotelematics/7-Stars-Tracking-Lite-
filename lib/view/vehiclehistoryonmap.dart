import 'dart:async';

import 'package:autotelematic_new_app/cubit/device_history_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/playbackroutemodel.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HistoryItem {
  final int type;
  final dynamic item;
  final DateTime timestamp;

  HistoryItem(
      {required this.type, required this.item, required this.timestamp});
}

class VehicleHistoryOnMapScreen extends StatefulWidget {
  final DeviceDataForReportsAndHistory deviceDataForReportsAndHistory;
  const VehicleHistoryOnMapScreen({
    super.key,
    required this.deviceDataForReportsAndHistory,
  });

  @override
  State<VehicleHistoryOnMapScreen> createState() =>
      _VehicleHistoryOnMapScreenState();
}

class _VehicleHistoryOnMapScreenState extends State<VehicleHistoryOnMapScreen> {
  final cubit = DeviceHistoryCubit();
  final panelController = PanelController();
  final mapController = Completer<GoogleMapController>();
  double currentZoom = 10; // Initial zoom level to show complete track
  double extraZoom = 17;
  bool isPlaying = false;
  MapType currentMapType = MapType.normal;
  var playIcon = Icons.play_circle_outline;
  Timer? playTimer;
  late LatLngBounds tripBounds;
  BitmapDescriptor? carIcon;
  BitmapDescriptor? pinIcon;
  late String startDate, endDate;

  String _formatPointTime(dynamic time, {dynamic rawTime}) {
    final s = (time ?? rawTime)?.toString();
    if (s == null || s.trim().isEmpty) return '—';

    final candidates = [
      // 24-hour inputs
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yy HH:mm:ss',
      'MM-dd-yyyy HH:mm:ss',

      // 12-hour inputs
      'dd-MM-yyyy hh:mm:ss a',
      'dd-MM-yy hh:mm:ss a',
      'MM-dd-yyyy hh:mm:ss a',
    ];

    for (final p in candidates) {
      try {
        final dt = DateFormat(p, 'en_US').parseStrict(s);
        return DateFormat('dd MMM yy hh:mm:ss a', 'en_US').format(dt);
        // Format: "12 Jan 2026 12:52:14 AM"

      } catch (_) {}
    }

    return s; // fallback
  }
  @override
  void initState() {
    super.initState();
    // Fetch route history from API
    cubit.fetchDeviceRoutHisotyFromApi(
      widget.deviceDataForReportsAndHistory.deviceId!.toString(),
      widget.deviceDataForReportsAndHistory.fromDate!,
      widget.deviceDataForReportsAndHistory.toDate!,
      widget.deviceDataForReportsAndHistory.fromTime!,
      widget.deviceDataForReportsAndHistory.toTime!,
    );
    // Format start and end dates with time
    try {
      final dateFormat = DateFormat("yy-MM-dd");
      final timeFormat = DateFormat("HH:mm:ss");

      final startD = dateFormat.parse(widget.deviceDataForReportsAndHistory.fromDate!);
      final startT = timeFormat.parse(widget.deviceDataForReportsAndHistory.fromTime!);
      final startDateTime = DateTime(startD.year, startD.month, startD.day, startT.hour, startT.minute, startT.second);
      startDate = startDateTime.historyDateTime;

      final endD = dateFormat.parse(widget.deviceDataForReportsAndHistory.toDate!);
      final endT = timeFormat.parse(widget.deviceDataForReportsAndHistory.toTime!);
      final endDateTime = DateTime(endD.year, endD.month, endD.day, endT.hour, endT.minute, endT.second);
      endDate = endDateTime.historyDateTime;
    } catch (e) {
      // Fallback
      startDate = widget.deviceDataForReportsAndHistory.fromDate ?? '';
      endDate = widget.deviceDataForReportsAndHistory.toDate ?? '';
    }
    // Load car icon
    BitmapDescriptor.asset(
            const ImageConfiguration(), 'assets/images/car_icon6.png')
        .then((icon) => setState(() => carIcon = icon));
    // Load pin icon
    BitmapDescriptor.asset(
            const ImageConfiguration(), 'assets/images/pin_icon.png')
        .then((icon) => setState(() => pinIcon = icon));
  }

  Timer interval(Duration duration, void Function(Timer) func) =>
      Timer.periodic(duration, (timer) => func(timer));

  void playRoute() {
    if (cubit.routeList.isEmpty) return; // Prevent timer if routeList is empty
    // Cancel any existing timer to avoid multiple timers running
    playTimer?.cancel();
    playTimer = Timer.periodic(
      Duration(
          milliseconds: cubit.playBackTimeSpeed[cubit.selectedPlayBackSpeed]),
      (timer) {
        final index = cubit.currentSliderValue;
        if (index < cubit.routeList.length - 1) {
          cubit.playUsingSlider(index + 1);
          moveCamera(cubit.routeList[index + 1]);
        } else {
          timer.cancel();
          cubit.playUsingSlider(0);
          moveCamera(cubit.routeList[0]);
          playPausePressed();
        }
      },
    );
  }

  void playPausePressed() {
    setState(() {
      isPlaying = !isPlaying;
      playIcon =
          isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline;
      currentZoom = isPlaying ? extraZoom : currentZoom;
      cubit.updatePolylineColor(isPlaying ? Colors.green : Colors.blue);
    });
    if (isPlaying) {
      playRoute(); // Start playback with the current speed
    } else {
      playTimer?.cancel(); // Stop playback
      boundCamera(cubit.intialLatLngBond); // Show complete track when paused
    }
  }

  void moveCamera(PlayBackRoute pos, {bool forceMove = false}) async {
    final controller = await mapController.future;
    final target = LatLng(
      double.parse(pos.latitude.toString()),
      double.parse(pos.longitude.toString()),
    );
    if (forceMove || isPlaying) {
      // Move to specific position (used for alerts or playback)
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: currentZoom)));
      if (carIcon != null && pinIcon != null) {
        final marker = Marker(
          markerId: forceMove ? const MarkerId('alert') : const MarkerId('car'),
          position: target,
          icon: forceMove ? pinIcon! : carIcon!,
          rotation: double.tryParse(pos.course.toString()) ?? 0.0,
          zIndex: 10,
        );
        if (forceMove) {
          cubit.addMarker(marker);
        }
      }
    } else {
      // Show complete track when not playing and not forced
      controller.animateCamera(
          CameraUpdate.newLatLngBounds(cubit.intialLatLngBond, 150));
    }
  }

  void boundCamera(LatLngBounds bounds) async {
    (await mapController.future)
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 150));
  }

  void googleMapCameraBond(List<LatLng> trips) async {
    if (trips.isEmpty) return;
    double minLat = trips.first.latitude, maxLat = trips.first.latitude;
    double minLng = trips.first.longitude, maxLng = trips.first.longitude;

    for (var p in trips) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void currentMapStatus(CameraPosition position) => currentZoom = position.zoom;

  @override
  void dispose() {
    playTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocProvider<DeviceHistoryCubit>(
        create: (_) => cubit,
        child: BlocBuilder<DeviceHistoryCubit, DeviceHistoryState>(
          builder: (context, state) {
            if (state is DeviceHistoryLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.loadingImage,
                    const SizedBox(height: 5),
                    const Text('Loading...'),
                  ],
                ),
              );
            }
            if (state is DeviceHistoryError) {
              return Center(
                child: Container(
                  width: size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[600]),
                      const SizedBox(height: 16),
                      Text(
                        'Error Fetching History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is DeviceHistoryLoadingComplete ||
                state is DeviceHistoryRefresh) {
              if (cubit.routeList.isEmpty) {
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition:
                          const CameraPosition(target: LatLng(0, 0), zoom: 0),
                      markers: cubit.mapMarkers.toSet(),
                      onMapCreated: mapController.complete,
                      onCameraMove: currentMapStatus,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      polylines: cubit.routPolyLine,
                    ),
                    Center(
                      child: Container(
                        width: size.width * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Trip History',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No trip data found for the selected date and time range.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: cubit.polyLatLng.first,
                      zoom: 16,
                    ),
                    zoomControlsEnabled: false,
                    markers: cubit.mapMarkers.toSet(),
                    onMapCreated: (controller) {
                      mapController.complete(controller);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                              cubit.intialLatLngBond, 150),
                        );
                      });
                    },
                    myLocationEnabled: false,
                    onCameraMove: currentMapStatus,
                    mapType: currentMapType,
                    myLocationButtonEnabled: false,
                    polylines: cubit.routPolyLine,
                    padding: EdgeInsets.only(bottom: size.height * 0.35),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.34),
                          _buildFAB(Icons.map, () {
                            setState(() => currentMapType =
                                currentMapType == MapType.normal
                                    ? MapType.hybrid
                                    : MapType.normal);
                            cubit.resetGoogleMap();
                          }),
                          _buildFAB(Icons.arrow_back, () async {
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            Navigator.pop(context);
                          }, heroTag: UniqueKey()),
                        ],
                      ),
                    ],
                  ),
                  SlidingUpPanel(
                    minHeight: size.height * 0.35,
                    controller: panelController,
                    maxHeight: size.height,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                    color: const Color.fromARGB(166, 255, 255, 255),
                    panelBuilder: (sc) =>
                        _scrollingList(sc, panelController, cubit),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildFAB(IconData icon, VoidCallback onPressed, {Object? heroTag}) =>
      Padding(
        padding: const EdgeInsets.all(5),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          heroTag: heroTag,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.black54),
        ),
      );

  Widget _scrollingList(ScrollController sc, PanelController panelController,
      DeviceHistoryCubit value) {
    final size = MediaQuery.of(context).size;

    // Create unified list of trips and alerts
    List<HistoryItem> historyItems = [];

    // Add trips/stops
    for (var trip in value.tripsList) {
      final tripStartTime = DateTime.tryParse(trip.rawTime.toString()) ??
          DateTime(1970, 1, 1); // Fallback for invalid time
      historyItems.add(HistoryItem(
        type: 1,
        item: trip,
        timestamp: tripStartTime,
      ));
    }

    // Add alerts
    for (var item in value.deviceHistoryModel.items!) {
      if (item.status == 5 && item.statusItems.isNotEmpty) {
        final details = item.statusItems[0];
        final alertTime =
            DateTime.tryParse(details['raw_time']?.toString() ?? '') ??
                DateTime(1970, 1);
        historyItems.add(HistoryItem(
          type: 2,
          item: item,
          timestamp: alertTime,
        ));
      }
    }

    // Sort by timestamp
    historyItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView(
      controller: sc,
      children: [
        InkWell(
          onTap: () => panelController.isPanelOpen
              ? panelController.close()
              : panelController.open(),
          child: const Center(
              child: Icon(Icons.keyboard_arrow_up_rounded, size: 35)),
        ),
        Container(
          width: size.width - 30,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 2, color: Color.fromARGB(255, 155, 150, 150))
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(7)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                child: Text(value.deviceName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateRow('From : ', startDate),
                  _buildDateRow('To : ', endDate),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoRow(
                      Icons.speed,
                      '${value.routeList[value.currentSliderValue].speed}',
                      Colors.black,
                      " KM/h",
                      ''),
                  _buildInfoRow(
                      Icons.access_alarm,
                      _formatPointTime(
                        value.routeList[value.currentSliderValue].time,
                        rawTime:
                            value.routeList[value.currentSliderValue].rawTime,
                      ),
                      Colors.black,
                      '',
                      ''),
                  _buildInfoRow(
                      Icons.directions_car,
                      '${double.parse(value.routeList[value.currentSliderValue].distance!).toStringAsFixed(2)} km',
                      Colors.black,
                      '',
                      ''),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        playPausePressed();
                        if (isPlaying) {
                          value.playUsingSlider(value.currentSliderValue + 1);
                          moveCamera(value.routeList[value.currentSliderValue]);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(1),
                        backgroundColor:
                            isPlaying ? Colors.green[100] : Colors.grey[200],
                      ),
                      child: Icon(playIcon,
                          size: 34,
                          color:
                              isPlaying ? Colors.green[700] : Colors.black54),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Slider(
                      activeColor: Colors.grey[400],
                      thumbColor: Colors.grey[400],
                      label: _formatPointTime(
                        value.routeList[value.currentSliderValue].time,
                        rawTime: value.routeList[value.currentSliderValue].rawTime,
                      ),
                      divisions: value.sliderValueMax,
                      min: 0,
                      max: value.sliderValueMax.toDouble(),
                      value: value.currentSliderValue.toDouble(),
                      onChanged: (sliderValue) {
                        final index = sliderValue.round();
                        if (index < value.routeList.length - 1) {
                          moveCamera(value.routeList[index]);
                          value.playUsingSlider(index);
                        } else {
                          value.playUsingSlider(0);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        value.setPlayBackSpeed();
                        if (isPlaying) {
                          playRoute(); // Restart timer with new speed
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(1),
                        backgroundColor: Colors.grey[200],
                      ),
                      child: Text('${value.selectedPlayBackSpeed + 1}x',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatText('Total Distance: ',
                      value.deviceHistoryModel.distanceSum.toString()),
                  _buildStatText('Maximum Speed: ',
                      value.deviceHistoryModel.topSpeed.toString()),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  _buildProgressCard(
                      'Travel Time (Trips: ${value.tripCount})',
                      value.deviceHistoryModel.moveDuration.toString(),
                      Colors.green,
                      0.23),
                  _buildProgressCard(
                      'Stop Time (Stops: ${value.stopCount})',
                      value.deviceHistoryModel.stopDuration.toString(),
                      Colors.red,
                      0.77),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final historyItem = historyItems[index];
            if (historyItem.type == 1) {
              final trip = historyItem.item;
              final cardColor = trip.status == 1 ? Colors.green : Colors.red;
              return InkWell(
                onTap: () {
                  panelController.close();
                  if (trip.status == 2) {
                    currentZoom = extraZoom;
                    moveCamera(trip.tripPlayBackRout[0], forceMove: true);
                  } else if (trip.status == 1) {
                    currentZoom = currentZoom;
                    value.removeSingleRoutPolyLineLatLng();
                    value.setSingleRoutPolyLineLatLng(trip.tripRoutLatLng);
                    tripBounds =
                        value.calculateCarFocusedBounds(trip.tripRoutLatLng);
                    boundCamera(tripBounds);
                    final tripIndex = value.routeList.indexWhere((route) =>
                        route.latitude ==
                            trip.tripRoutLatLng.first.latitude.toString() &&
                        route.longitude ==
                            trip.tripRoutLatLng.first.longitude.toString());
                    value.playUsingSlider(tripIndex);
                  }
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            trip.status == 1
                                ? _buildInfoRow(Icons.directions_car,
                                    '${trip.distance} Km', cardColor, ' KM', '')
                                : const SizedBox.shrink(),
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 3),
                              child: Text(
                                trip.status == 1 ? 'Trip' : 'Stop',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            trip.status == 1
                                ? _buildInfoRow(
                                    Icons.speed,
                                    '${trip.topSpeed} kph',
                                    cardColor,
                                    ' KM/h',
                                    'Speed ')
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const Divider(),
                        _buildTripRow(Icons.play_circle_outline_outlined,
                            'Start:', trip.tripStart.toString()),
                        const Divider(),
                        _buildTripRow(Icons.alarm, 'Duration:',
                            trip.totalTripDuration.toString()),
                        const Divider(),
                        _buildTripRow(Icons.stop_circle_outlined, 'End:',
                            trip.tripEnd.toString()),
                      ],
                    ),
                  ),
                ),
              );
            } else if (historyItem.type == 2) {
              final item = historyItem.item;
              final cardColor =
                  item.status == 5 ? Colors.yellow[700]! : Colors.grey;
              final details = item.statusItems[0];
              return InkWell(
                onTap: () {
                  panelController.close();
                  currentZoom = extraZoom;
                  final lat = double.tryParse(details['lat'].toString()) ?? 0.0;
                  final lng = double.tryParse(details['lng'].toString()) ?? 0.0;
                  final alertPosition = PlayBackRoute(
                    latitude: lat.toString(),
                    longitude: lng.toString(),
                    course: '0',
                  );
                  value.addMarker(
                    Marker(
                      markerId: MarkerId('alert_${details['raw_time']}'),
                      position: LatLng(lat, lng),
                      icon: value.eventsIcon,
                      zIndex: 5,
                    ),
                  );
                  moveCamera(alertPosition, forceMove: true);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoRow(
                                Icons.warning,
                                item.message ?? 'No message',
                                cardColor,
                                '',
                                ''),
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 3),
                              child: const Text(
                                'Alert',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            _buildInfoRow(
                                Icons.speed,
                                '${details['speed']} kph',
                                cardColor,
                                '',
                                'Speed '),
                          ],
                        ),
                        const Divider(),
                        _buildTripRow(
                            Icons.warning, 'Message:', item.message ?? 'N/A'),
                        const Divider(),
                        _buildTripRow(Icons.access_time, 'Time:',
                            details['time'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDateRow(String label, String date) => Row(
        children: [
          const Icon(Icons.calendar_month_outlined,
              color: Colors.grey, size: 17),
          const VerticalDivider(width: 2),
          Text.rich(
            TextSpan(
              text: label,
              children: [
                TextSpan(
                    text: date,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      );

  Widget _buildInfoRow(IconData icon, String text, Color color, String kmText,
      String lableSpeed) =>
      Row(
        children: [
          Text(
            lableSpeed,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w500, fontSize: 14.sp),
          ),
          Icon(icon, color: color, size: 17),
          SizedBox(
            width: 3,
          ),
          Text(
            text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w500, fontSize: 14.sp),
          ),

          Text(
            kmText,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w500, fontSize: 14.sp),
          ),
        ],
      );

  Widget _buildStatText(String label, String value) => RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
          children: [
            TextSpan(
                text: value,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))
          ],
        ),
      );

  Widget _buildProgressCard(
          String title, String value, MaterialColor color, double percentage) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color[50], borderRadius: BorderRadius.circular(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.black87, fontSize: 10)),
              GFProgressBar(
                margin: const EdgeInsets.all(3),
                percentage: percentage,
                lineHeight: 5,
                backgroundColor: Colors.black26,
                progressBarColor: color,
              ),
              Text(value,
                  style: const TextStyle(color: Colors.black87, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _buildTripRow(IconData icon, String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 17, color: Colors.grey),
            const VerticalDivider(width: 3),
            Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 12))
          ]),
          Text(value,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      );
}
