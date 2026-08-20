import 'package:autotelematic_new_app/cubit/get_devices_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class DeviceInfoCardStyle extends StatefulWidget {
  final String name;
  final String groupTitle;
  final String speed;
  final String vehicleStatus;
  final String stopTime;
  final String lastUpdateTime;
  final String iconPathfromApi;
  final bool immobilizerValue;
  final String batteryVoltage;
  final Color backgroundColor;
  final Color vehicleStatusColor;
  final Color keyColor;
  final String batteryCharging;
  final double deviceLat;
  final double deviceLng;
  final String address;
  final String network;

  const DeviceInfoCardStyle({
    required this.name,
    required this.groupTitle,
    required this.speed,
    required this.vehicleStatus,
    required this.stopTime,
    required this.lastUpdateTime,
    required this.iconPathfromApi,
    required this.immobilizerValue,
    required this.batteryVoltage,
    required this.backgroundColor,
    required this.vehicleStatusColor,
    required this.keyColor,
    required this.batteryCharging,
    required this.deviceLat,
    required this.deviceLng,
    required this.address,
    required this.network,
    super.key,
  });

  @override
  State<DeviceInfoCardStyle> createState() => _DeviceInfoCardStyleState();
}

class _DeviceInfoCardStyleState extends State<DeviceInfoCardStyle> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(1.3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Vehicle Name and Group
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.name.isNotEmpty ? widget.name : 'Unknown Vehicle',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.vehicleStatusColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Row(
                //   children: [
                //     Text(
                //       'Group: ',
                //       style: TextStyle(
                //         fontSize: 15.sp,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.grey[700],
                //       ),
                //     ),
                //     Text(
                //       widget.groupTitle.isNotEmpty
                //           ? widget.groupTitle
                //           : 'No Group',
                //       style: TextStyle(
                //         fontSize: 15.sp,
                //         fontWeight: FontWeight.w600,
                //         color: widget.groupTitle.toLowerCase() == 'ungrouped'
                //             ? Colors.red
                //             : Colors.green[700],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            SizedBox(height: 1.3.h),
            // Main Content: Icon and Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Icon
                SizedBox(
                  width: 16.3.w,
                  height: 8.4.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.iconPathfromApi.isNotEmpty
                          ? '${ApiEndpointUrls.baseImgURL}${widget.iconPathfromApi}'
                          : 'https://via.placeholder.com/80',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.amberAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 1.3.h),
                // Vehicle Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Speed',
                        '${widget.speed} km/h',
                        Icons.speed,
                        Colors.black87,
                      ),
                      SizedBox(height: 1.h),
                      _buildDetailRow(
                        'Status',
                        widget.vehicleStatus.isNotEmpty
                            ? (
                            widget.vehicleStatus.toLowerCase() == 'stopped' && widget.stopTime.isNotEmpty
                                ? '${widget.vehicleStatus} (${context.read<GetDevicesListCubit>().formatDuration(
                              context.read<GetDevicesListCubit>().parseStopDuration(widget.stopTime),
                            )})'
                                : widget.vehicleStatus
                        )
                            : 'Unknown',
                        Icons.donut_large,
                        widget.vehicleStatusColor,
                      ),

                      SizedBox(height: 1.h),
                      _buildDetailRow(
                        'Last Updated',
                        widget.lastUpdateTime.isNotEmpty
                            ? widget.lastUpdateTime
                            : 'N/A',
                        Icons.access_time,
                        Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.3.h),
            // Status Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 1.3.w,
                  runSpacing: 8,
                  children: [
                    _buildStatusIcon(
                      icon: widget.immobilizerValue
                          ? Icons.lock
                          : Icons.lock_open,
                      color:
                      widget.immobilizerValue ? Colors.red : Colors.green,
                      label: 'Immobilizer',
                      value: widget.immobilizerValue ? 'On' : 'Off',
                    ),
                    _buildStatusIcon(
                      icon: Icons.signal_cellular_alt,
                      color: Colors.orange,
                      label: 'Connection',
                      value:widget.network ,
                    ),
                    _buildStatusIcon(
                      icon: Icons.key,
                      color: widget.keyColor,
                      label: 'Ignition',
                      value: widget.keyColor == Colors.green ? 'On' : 'Off',
                    ),
                    _buildStatusIcon(
                      icon: Icons.battery_charging_full,
                      color: widget.batteryCharging=="true"?Colors.green:Colors.red,
                      label: 'Charging',
                      value:  widget.batteryCharging=="true"
                          ? 'On'
                          : 'Off',
                    ),
                    _buildStatusIcon(
                      icon: Icons.satellite_alt_sharp,
                      color: Colors.green,
                      label: 'Battery',
                      value: widget.batteryVoltage.isNotEmpty
                          ? widget.batteryVoltage
                          : 'N/A',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.3.h),
            // Address
            Row(
              children: [
                Icon(Icons.location_on, size: 22, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.address.isNotEmpty ? widget.address : 'Unknown Address',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row for displaying vehicle details (e.g., speed, status).
  Widget _buildDetailRow(
      String label,
      String value,
      IconData icon,
      Color valueColor,
      ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        SizedBox(width: 1.h),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds a status icon with a tooltip (e.g., immobilizer, ignition).
  Widget _buildStatusIcon({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Tooltip(
      message: '$label: $value',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 14,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}