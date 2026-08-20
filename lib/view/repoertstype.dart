import 'dart:developer';
import 'package:autotelematic_new_app/cubit/reportstype_cubit.dart';
import 'package:autotelematic_new_app/cubit/reportstype_state.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/geofence_model.dart';
import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/app_constants.dart';
import 'package:autotelematic_new_app/utils/date_time_extension.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/model/reporttypemodel.dart' as model;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../cubit/geofencing_state.dart' show GeofencingCubit, GeofencingState, GeofencingInitial, GeofencingLoading, GeofencingError, GeofencingLoaded;

class ReportTypesScreen extends StatefulWidget {
  final DeviceDataForReportsAndHistory deviceDataForReportsAndHistory;

  const ReportTypesScreen({
    super.key,
    required this.deviceDataForReportsAndHistory,
  });

  @override
  State<ReportTypesScreen> createState() => _ReportTypesScreenState();
}

class _ReportTypesScreenState extends State<ReportTypesScreen> {
  final TextEditingController _speedLimitController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  int? _selectedMinutes;
  bool _showMoreReports = false;
  String startDate = '', endDate = '';

  final List<int> excludedReportTypes = [63, 57, 54, 55, 46, 32, 44, 28, 19, 62];
  final List<int> prioritizedReportTypes = [1, 3, 34, 7, 25, 43, 48, 8];

  final Map<int, IconData> reportIcons = {
    1: Icons.map_rounded,
    3: Icons.directions_car_rounded,
    34: Icons.speed_rounded,
    7: Icons.location_on_rounded,
    25: Icons.history_rounded,
    43: Icons.play_circle_filled_rounded,
    48: Icons.calendar_today_rounded,
    8: Icons.warning_rounded,
  };

  final _dialogBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp));
  final _buttonBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp));
  final _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.sp),
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 0, blurRadius: 5, offset: Offset(2, 2))],
  );

  bool _isDataValid() =>
      widget.deviceDataForReportsAndHistory.fromDate != null &&
          widget.deviceDataForReportsAndHistory.toDate != null &&
          widget.deviceDataForReportsAndHistory.deviceId != null &&
          widget.deviceDataForReportsAndHistory.deviceId! > 0;

  void _navigateToReport(BuildContext context, int reportType, {int speedLimit = 0, List<int> geofenceIds = const [], int minutes = 0, String reportName = ""}) {
    if (_isDataValid()) {
      String format = reportType == 43 ? 'html' : 'pdf';
      Navigator.pushNamed(context, RoutesName.viewReport,
          arguments: ViewReportIntialData(
            widget.deviceDataForReportsAndHistory.fromDate!,
            widget.deviceDataForReportsAndHistory.toDate!,
            widget.deviceDataForReportsAndHistory.deviceId!,
            format,
            reportType,
            speedLimit,
            geofenceIds,
            minutes,
            reportName,
            widget.deviceDataForReportsAndHistory.fromTime ?? "",
            widget.deviceDataForReportsAndHistory.toTime ?? "",
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid date or device ID')));
    }
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTheme.loadingImage,
        SizedBox(height: 2.h),
        Text('Loading...', style: TextStyle(fontSize: 14.sp)),
      ],
    ),
  );

  void _showSpeedLimitDialog(BuildContext context, int reportType, String reportName) {
    _speedLimitController.clear(); // Reset controller
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: _dialogBorder,
        title: Text('Enter Speed Limit', style: TextStyle(fontSize: 14.sp)),
        content: Container(
          width: 80.w,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: TextField(
            controller: _speedLimitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Speed Limit (km/h)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
              contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: _buttonBorder, backgroundColor: AppColors.reportIconsColor),
            onPressed: () {
              if (_speedLimitController.text.isNotEmpty) {
                final speedLimit = int.tryParse(_speedLimitController.text);
                if (speedLimit != null && _isDataValid()) {
                  Navigator.pop(ctx);
                  _navigateToReport(context, reportType, speedLimit: speedLimit, reportName: reportName);
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid speed limit or missing date/device ID')));
                }
              }
            },
            child: Text('Generate Report', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGeofenceSelectionDialog(BuildContext parentContext, int reportType, String reportName) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: parentContext.read<GeofencingCubit>(),
        child: AlertDialog(
          shape: _dialogBorder,
          title: Text('Select Geofences', style: TextStyle(fontSize: 14.sp)),
          content: SizedBox(
            width: 80.w,
            height: 50.h,
            child: BlocBuilder<GeofencingCubit, GeofencingState>(
              builder: (context, state) {
                if (state is GeofencingInitial) {
                  context.read<GeofencingCubit>().loadGeofencingData();
                  return _buildLoading();
                }
                if (state is GeofencingLoading) return _buildLoading();
                if (state is GeofencingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: TextStyle(fontSize: 14.sp), textAlign: TextAlign.center),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: _buttonBorder),
                          onPressed: () => context.read<GeofencingCubit>().loadGeofencingData(),
                          child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ],
                    ),
                  );
                }
                if (state is GeofencingLoaded) {
                  final geofences = state.model.items.geofences;
                  if (geofences.isEmpty) return Center(child: Text('No Geofences Available', style: TextStyle(fontSize: 14.sp)));
                  return ListView.builder(
                    itemCount: geofences.length,
                    itemBuilder: (context, index) {
                      final geofence = geofences[index];
                      return CheckboxListTile(
                        title: Text(geofence.name, style: TextStyle(fontSize: 14.sp)),
                        value: geofence.isSelected,
                        onChanged: (bool? value) =>
                            context.read<GeofencingCubit>().toggleGeofenceSelection(index, value ?? false),
                      );
                    },
                  );
                }
                return Center(child: Text('No Geofences Available', style: TextStyle(fontSize: 14.sp)));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            BlocBuilder<GeofencingCubit, GeofencingState>(
              builder: (context, state) {
                bool isAnySelected = state is GeofencingLoaded && state.model.items.geofences.any((g) => g.isSelected);
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: _buttonBorder, backgroundColor: AppColors.reportIconsColor),
                  onPressed: isAnySelected
                      ? () {
                    final selectedGeofenceIds = (state)
                        .model
                        .items
                        .geofences
                        .asMap()
                        .entries
                        .where((entry) => entry.value.isSelected)
                        .map((entry) => entry.value.id)
                        .toList();
                    Navigator.pop(dialogContext);
                    _navigateToReport(parentContext, reportType, geofenceIds: selectedGeofenceIds, reportName: reportName);
                  }
                      : null,
                  child: Text('Generate Report', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                );
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      final cubit = context.read<GeofencingCubit>();
      if (cubit.state is GeofencingLoaded) {
        final currentState = cubit.state as GeofencingLoaded;
        final updatedGeofences = List<Geofence>.from(currentState.model.items.geofences)..forEach((g) => g.isSelected = false);
        cubit.emit(GeofencingLoaded(GeofenceResponse(items: GeofenceItems(geofences: updatedGeofences), status: currentState.model.status)));
      }
    });
  }

  void _showMinutesSelectionDialog(BuildContext context, int reportType, String reportName) {
    _minutesController.clear(); // Reset controller
    _selectedMinutes = null; // Reset selected minutes
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          shape: _dialogBorder,
          title: Text('Enter Duration', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          content: Container(
            width: 80.w,
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration (Minutes)',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                  ),
                  onChanged: (value) {
                    dialogSetState(() => _selectedMinutes = int.tryParse(value));
                    debugPrint('Entered minutes: $_selectedMinutes');
                  },
                ),
                SizedBox(height: 1.h),
                Text(
                  'Only enter minutes to generate the report.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: _buttonBorder, backgroundColor: AppColors.reportIconsColor),
              onPressed: _selectedMinutes != null && _selectedMinutes! > 0
                  ? () {
                log("Generating report with minutes: $_selectedMinutes");
                Navigator.pop(dialogContext);
                _navigateToReport(context, reportType, minutes: _selectedMinutes!, reportName: reportName);
              }
                  : null,
              child: Text('Generate Report', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing ReportTypesScreen');
    context.read<ReportstypeCubit>().fetchReportsTypeFromApi();

    // Format start and end dates with time
    try {
      final dateFormat = DateFormat("yy-MM-dd");
      final timeFormat = DateFormat("HH:mm:ss");

      final startD =
          dateFormat.parse(widget.deviceDataForReportsAndHistory.fromDate!);
      final startT =
          timeFormat.parse(widget.deviceDataForReportsAndHistory.fromTime!);
      final startDateTime = DateTime(startD.year, startD.month, startD.day,
          startT.hour, startT.minute, startT.second);
      startDate = startDateTime.historyDateTime;

      final endD =
          dateFormat.parse(widget.deviceDataForReportsAndHistory.toDate!);
      final endT =
          timeFormat.parse(widget.deviceDataForReportsAndHistory.toTime!);
      final endDateTime = DateTime(endD.year, endD.month, endD.day, endT.hour,
          endT.minute, endT.second);
      endDate = endDateTime.historyDateTime;
    } catch (e) {
      // Fallback
      startDate = widget.deviceDataForReportsAndHistory.fromDate ?? '';
      endDate = widget.deviceDataForReportsAndHistory.toDate ?? '';
    }
  }

  @override
  void dispose() {
    _speedLimitController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_outlined, size: 2.5.h, color: const Color(0xFF212121)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Reports', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19.sp, color: const Color(0xFF212121))),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.5.h, bottom: .5.h, left: 3.5.w, right: 3.5.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: _cardDecoration,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_filled_rounded, size: 18.sp, color: AppColors.primaryColor),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        widget.deviceDataForReportsAndHistory.deviceTitle ?? 'Unknown Vehicle',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF424242)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Divider(height: 2.h, color: Colors.grey[200]),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From:', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 14.sp, color: AppColors.primaryColor),
                              SizedBox(width: 1.w),
                              Text(
                                startDate,
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF616161), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(height: 4.h, width: 1, color: Colors.grey[300]),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To:', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 14.sp, color: AppColors.primaryColor),
                              SizedBox(width: 1.w),
                              Text(
                                endDate,
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF616161), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<ReportstypeCubit, ReportstypeState>(
            builder: (context, state) {
              if (state is ReportstypeInitial) {
                context.read<ReportstypeCubit>().fetchReportsTypeFromApi();
                return Expanded(child: _buildLoading());
              }
              if (state is ReportstypeLoading) {
                return Expanded(child: _buildLoading());
              }
              if (state is ReportstypeError) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF212121))),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: _buttonBorder, backgroundColor: AppColors.reportIconsColor),
                          onPressed: () => context.read<ReportstypeCubit>().fetchReportsTypeFromApi(),
                          child: Text('Retry', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is ReportstypeLoadingComplete) {
                List<model.Items> prioritizedItems =
                    state.reportTypeModel.items?.where((item) => prioritizedReportTypes.contains(item.type)).toList() ?? [];
                List<model.Items> otherItems = state.reportTypeModel.items
                    ?.where((item) => !prioritizedReportTypes.contains(item.type) && !excludedReportTypes.contains(item.type))
                    .toList() ??
                    [];

                // If prioritized items are empty but we have other reports, move them to prioritized
                if (prioritizedItems.isEmpty && otherItems.isNotEmpty) {
                  prioritizedItems = List.from(otherItems);
                  otherItems = [];
                }

                if (prioritizedItems.isEmpty && otherItems.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No report categories found',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.read<ReportstypeCubit>().fetchReportsTypeFromApi(),
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.w,
                              mainAxisSpacing: 1.h,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: prioritizedItems.length,
                            itemBuilder: (context, index) {
                              final item = prioritizedItems[index];
                              final reportType = item.type;
                              final reportName = item.name.toString();
                              final url = item.formats;
                              log("Report Type: $reportType, Name: $reportName, Formats: $url");
                              return GestureDetector(
                                onTap: () {
                                  debugPrint('Selected report type: $reportType - $reportName');
                                  if (reportType == 5) {
                                    _showSpeedLimitDialog(context, reportType ?? 0, reportName);
                                  } else if (reportType == 7) {
                                    _showGeofenceSelectionDialog(context, reportType ?? 0, reportName);
                                  } else if (reportType == 30) {
                                    _showMinutesSelectionDialog(context, reportType ?? 0, reportName);
                                  } else {
                                    _navigateToReport(context, reportType ?? 0, reportName: reportName);
                                  }
                                },
                                child: Container(
                                  decoration: _cardDecoration,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        reportIcons[reportType] ?? Icons.report_rounded,
                                        size: 30.sp,
                                        color: AppColors.reportIconsColor,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        reportType == 8
                                            ? "Alerts Report"
                                            : reportType == 3
                                            ? "Trip Report"
                                            : reportName,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF212121),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (otherItems.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.reportIconsColor,
                                shape: _buttonBorder,
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                              ),
                              onPressed: () => setState(() => _showMoreReports = !_showMoreReports),
                              child: Text(
                                _showMoreReports ? 'Show Less' : 'See More',
                                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        if (_showMoreReports)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            child: Column(
                              children: otherItems.map<Widget>((item) {
                                final reportType = item.type;
                                final reportName = item.name.toString();
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: GestureDetector(
                                    onTap: () {
                                      debugPrint('Selected report type: $reportType - $reportName');
                                      if (reportType == 5) {
                                        _showSpeedLimitDialog(context, reportType ?? 0, reportName);
                                      } else if (reportType == 7) {
                                        _showGeofenceSelectionDialog(context, reportType ?? 0, reportName);
                                      } else if (reportType == 30) {
                                        _showMinutesSelectionDialog(context, reportType ?? 0, reportName);
                                      } else {
                                        _navigateToReport(context, reportType ?? 0, reportName: reportName);
                                      }
                                    },
                                    child: Container(
                                      decoration: _cardDecoration,
                                      padding: EdgeInsets.all(4.w),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.report_rounded,
                                            size: 24.sp,
                                            color: AppColors.reportIconsColor,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              reportName,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF212121),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(child: _buildLoading());
            },
          ),
        ],
      ),
    );
  }
}