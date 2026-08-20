import 'package:autotelematic_new_app/model/get_alerts_list_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventsOnMapScreen extends StatefulWidget {
  final Item eventData;
  const EventsOnMapScreen({super.key, required this.eventData});

  @override
  State<EventsOnMapScreen> createState() => _EventsOnMapScreenState();
}

class _EventsOnMapScreenState extends State<EventsOnMapScreen> {
  final List<Marker> _markers = [];
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.eventData.latitude != 0.0 && widget.eventData.longitude != 0.0) {
      _markers.add(
        Marker(
          markerId: const MarkerId('event_marker'),
          position: LatLng(widget.eventData.latitude, widget.eventData.longitude),
          infoWindow: InfoWindow(title: widget.eventData.deviceName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidCoordinates = widget.eventData.latitude != 0.0 && widget.eventData.longitude != 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          hasValidCoordinates
              ? GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.eventData.latitude, widget.eventData.longitude),
              zoom: 15,
            ),
            markers: Set<Marker>.of(_markers),
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_markers.isNotEmpty) {
                _controller?.showMarkerInfoWindow(const MarkerId('event_marker'));
              }
            },
          )
              : const Center(
            child: Text(
              'Location data unavailable',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      Icons.notifications_none_outlined,
                      widget.eventData.message,
                      color: Colors.red,
                    ),
                    _infoRow(
                      Icons.alarm,
                      widget.eventData.time?.toLocal().toString() ?? 'No time available',
                    ),
                    _infoRow(
                      Icons.speed,
                      '${widget.eventData.speed} km/h',
                    ),
                    _infoRow(
                      Icons.pin_drop_outlined,
                      widget.eventData.address.isNotEmpty ? widget.eventData.address : 'No address available',
                      color: Colors.grey[800],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.black, size: 20.sp),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
                color: color ?? Colors.black87,
                fontSize: 16.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}