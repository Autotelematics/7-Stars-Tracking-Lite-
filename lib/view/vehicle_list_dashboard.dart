import 'dart:math';

import 'package:autotelematic_new_app/cubit/get_device_group_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_group_state.dart';
import 'package:autotelematic_new_app/cubit/get_devices_list_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_devices_list_state.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/view/customreportandhistory.dart';
import 'package:autotelematic_new_app/view/devicecommands.dart';
import 'package:autotelematic_new_app/widgets/circular_image_widget.dart';
import 'package:autotelematic_new_app/widgets/decive_card_style.dart';
import 'package:autotelematic_new_app/widgets/filter_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../model/get_device_group_model.dart' show GetDeviceGroupModelItem;

class VehicleListDashBoardScreen extends StatefulWidget {
  const VehicleListDashBoardScreen({super.key});

  @override
  State<VehicleListDashBoardScreen> createState() =>
      _VehicleListDashBoardScreenState();
}

class _VehicleListDashBoardScreenState
    extends State<VehicleListDashBoardScreen> {
  String vehicleCurrentStatusFromAPI = '';
  Color mainBoxbgColor = Colors.grey,
      vehicleStatusColor = Colors.grey,
      keyColor = Colors.grey,
      batteryChargingColor = Colors.grey;
  String vehicleStatus = '';
  List<dynamic>? sensorsData;
  String? batteryVoltage;
  bool immobilizerValue = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedDeviceIndex;
  final Map<String, bool> _immobilizerCache = {};
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  void processSensorData(List<dynamic>? sensorsData, String deviceId) {
    if (sensorsData == null || sensorsData.isEmpty) {
      _immobilizerCache[deviceId] = false;
      return;
    }
    bool newImmobilizerValue = false;
    for (var element in sensorsData) {
      final name = element.name?.toString().toLowerCase().trim() ?? '';
      final value = element.value?.toString().toLowerCase() ?? '';
      if (name == 'ignition') {
        keyColor = value == 'off'
            ? Colors.red[600]!
            : value == 'on'
                ? Colors.green[600]!
                : Colors.grey[600]!;
      } else if (element.type?.toString().toLowerCase() == 'battery') {
        batteryVoltage = element.value?.toString();
      } else if (name == 'charging') {
        batteryChargingColor = value == 'on'
            ? Colors.green[600]!
            : value == 'off'
                ? Colors.red[600]!
                : Colors.grey[600]!;
      } else if (name == 'immobiliser' || name == 'immobilizer') {
        newImmobilizerValue = value == 'on';
      }
    }
    _immobilizerCache[deviceId] = newImmobilizerValue;
    immobilizerValue = newImmobilizerValue;
  }

  void setVehicleStatusAndColors(String status, String time) {
    switch (status) {
      case 'ack':
        mainBoxbgColor = const Color(0xFFF8D7DA);
        vehicleStatus = 'Stopped';
        vehicleStatusColor = Colors.red[700]!;
        break;
      case 'online':
        mainBoxbgColor = const Color(0xFFE8F5E9);
        vehicleStatus = 'Running';
        vehicleStatusColor = Colors.green[700]!;
        break;
      case 'offline':
        if (time.toLowerCase() == 'not connected') {
          mainBoxbgColor = const Color(0xFFE0E0E0);
          vehicleStatus = 'No Data';
          vehicleStatusColor = Colors.grey[700]!;
        } else if (time.toLowerCase() == 'expired') {
          mainBoxbgColor = const Color(0xFFFBE9E7);
          vehicleStatus = 'Expired';
          vehicleStatusColor = const Color(0xFF7B1C1C);
        } else {
          mainBoxbgColor = const Color(0xFFE3F2FD);
          vehicleStatus = 'Offline';
          vehicleStatusColor = Colors.blue[700]!;
        }
        break;
      case 'engine':
        mainBoxbgColor = const Color(0xFFFFF3E0);
        vehicleStatus = 'Idle';
        vehicleStatusColor = Colors.orange[700]!;
        break;
      case 'black':
        mainBoxbgColor = const Color(0xFFFFF3E0);
        vehicleStatus = 'Parked';
        vehicleStatusColor = Colors.orange[700]!;
        break;
      default:
        mainBoxbgColor = const Color(0xFFE0E0E0);
        vehicleStatus = 'Disconnected';
        vehicleStatusColor = Colors.grey[800]!;
    }
  }

  Future<void> showDatePickerDialog(BuildContext context, String screenRout,
      String deviceName, int deviceID) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomeHistoryDateTimePicker(deviceName, deviceID, screenRout)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeviceCommandsPicker(
      int deviceID, GetDevicesListCubit cubit) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DeviceCommandsScreen(deviceID: deviceID),
      ),
    );
  }

  PopupMenuButton<int> buildPopupMenuButton(
    String route,
    String imagePath,
    int index,
    String label,
    List<dynamic> filteredDevices,
  ) {
    final dt = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-dd");
    // NOTE: use 24-hour if you ever format the current time for API
    final timeFormat24 = DateFormat("HH:mm:ss");

    return PopupMenuButton<int>(
      color: Colors.white,
      position: PopupMenuPosition.under,
      onSelected: (value) {
        // Defaults (safe for API)
        String toDate = dateFormat.format(dt);
        String fromDate = toDate;
        String fromTime = '00:00:01';
        String toTime = '23:59:59';

        switch (value) {
          case 0: // Today (full day)
            fromDate = toDate = dateFormat.format(dt);
            fromTime = '00:00:00';
            toTime = '23:59:59';
            break;

          case 1: // Yesterday (full day)
            fromDate = toDate =
                dateFormat.format(dt.subtract(const Duration(days: 1)));
            fromTime = '00:00:00';
            toTime = '23:59:59';
            break;

          case 7: // Last 7 Days (full 7 days including today)
            toDate = dateFormat.format(dt);
            fromDate = dateFormat.format(dt.subtract(const Duration(days: 6)));
            fromTime = '00:00:00';
            toTime = '23:59:59';
            break;

          case 2: // Custom Date → open picker and return
            showDatePickerDialog(
              context,
              route == RoutesName.viewHistory ? 'playroutonmap' : 'reporttype',
              filteredDevices[index].name?.toString() ?? 'Unknown',
              int.parse(filteredDevices[index].id?.toString() ?? '0'),
            );
            return;
        }

        // (Optional sanity: ensure range is not inverted)
        final from = DateTime.parse(fromDate);
        final to = DateTime.parse(toDate);
        if (to.isBefore(from)) {
          // swap if needed
          final tmp = fromDate;
          fromDate = toDate;
          toDate = tmp;
        }

        Navigator.pushNamed(
          context,
          route,
          arguments: DeviceDataForReportsAndHistory(
            deviceId:
                int.tryParse(filteredDevices[index].id?.toString() ?? '0') ?? 0,
            deviceTitle: filteredDevices[index].name?.toString() ?? 'Unknown',
            fromDate: fromDate,
            toDate: toDate,
            fromTime: fromTime,
            toTime: toTime,
          ),
        );
      },
      padding: EdgeInsets.zero,
      icon: CircularImageWidget(
        imagePath: imagePath,
        imageSize: 6.h,
        containerSize: 4.5.h,
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

  void _showGroupFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 50.h, maxWidth: 80.w),
          child: BlocBuilder<GetDeviceGroupCubit, GetDeviceGroupState>(
            builder: (context, state) {
              if (state.isLoading && state.model == null) {
                return Center(child: CircularProgressIndicator());
              } else if (state is GetDeviceGroupLoaded &&
                  state.model?.items != null) {
                final groups = state.model!.items!
                    .asMap()
                    .entries
                    .fold<Map<String, GetDeviceGroupModelItem>>(
                      {},
                      (map, entry) {
                        final group = entry.value;
                        final title = group.title?.toLowerCase().trim() ??
                            'unnamed group';
                        if (!map.containsKey(title)) {
                          map[title] = group;
                        }
                        return map;
                      },
                    )
                    .values
                    .toList();

                final allGroup =
                    GetDeviceGroupModelItem(id: -999, title: 'All', items: []);
                final groupList = [allGroup, ...groups];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      'Select Group',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(16),
                          itemCount: groupList.length,
                          itemBuilder: (context, index) {
                            final group = groupList[index];
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                title: Text(group.title ?? 'Unnamed Group'),
                                trailing: context
                                            .read<GetDevicesListCubit>()
                                            .state
                                            .groupFilter ==
                                        (group.id == -999
                                            ? 'all'
                                            : group.id.toString())
                                    ? Icon(Icons.check, color: Colors.blue)
                                    : null,
                                onTap: () {
                                  context
                                      .read<GetDevicesListCubit>()
                                      .setGroupFilter(
                                        group.id == -999
                                            ? 'all'
                                            : group.id.toString(),
                                        group.title ?? 'Unnamed Group',
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                final allGroup =
                    GetDeviceGroupModelItem(id: -999, title: 'All', items: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Group',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text('All'),
                        trailing: context
                                    .read<GetDevicesListCubit>()
                                    .state
                                    .groupFilter ==
                                'all'
                            ? Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          context
                              .read<GetDevicesListCubit>()
                              .setGroupFilter('all', 'All');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state is GetDeviceGroupError
                          ? state.errorMessage ?? 'Failed to load groups'
                          : 'No groups available',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<GetDevicesListCubit>()
            .fetchDevicesList(isRefresh: true, context: context);
        context.read<GetDeviceGroupCubit>().fetchDeviceGroups(isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFfdf3d9).withOpacity(0.4),
        endDrawer: BlocBuilder<GetDevicesListCubit, GetDevicesListState>(
          builder: (context, state) {
            if (_selectedDeviceIndex != null &&
                _selectedDeviceIndex! >= 0 &&
                _selectedDeviceIndex! < state.filteredDevices.length) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final drawerHeight =
                      min(53.h, MediaQuery.of(context).size.height * 0.7);
                  final iconSize = drawerHeight * 0.095;
                  final textSize = drawerHeight * 0.0245;
                  final paddingSize = drawerHeight * 0.0094;

                  final device = state.filteredDevices[_selectedDeviceIndex!];

                  vehicleCurrentStatusFromAPI =
                      device.online?.toString().toLowerCase() ?? '';
                  final vehicleTime =
                      device.time?.toString().toLowerCase() ?? '';
                  sensorsData = device.sensors as List<dynamic>?;
                  processSensorData(sensorsData, device.id?.toString() ?? '0');
                  setVehicleStatusAndColors(
                      vehicleCurrentStatusFromAPI, vehicleTime);

                  return SizedBox(
                    height: drawerHeight,
                    child: Drawer(
                      width: 20.w,
                      backgroundColor: Colors.white,
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: paddingSize),
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Icon(Icons.directions_car,
                              color: vehicleStatusColor, size: iconSize),
                          Text(
                            device.name?.toString() ?? 'Unknown Vehicle',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: textSize,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(color: Colors.grey),
                          _buildDrawerItem(
                            imagePath: 'assets/images/TrackOrder_48px.png',
                            label: 'Track',
                            imageSize: iconSize * 0.87,
                            paddingSize: paddingSize,
                            textSize: textSize,
                            onTap: () {
                              final deviceId =
                                  int.tryParse(device.id?.toString() ?? '0') ??
                                      0;
                              if (deviceId == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invalid device ID')),
                                );
                                return;
                              }
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, RoutesName.vehicleLiveTracking,
                                  arguments: {
                                    'groupID': 0,
                                    'deviceID': deviceId,
                                    'homeCubit':
                                        context.read<GetDevicesListCubit>(),
                                    'deviceID1': deviceId,
                                  });
                            },
                          ),
                          _buildDrawerItem(
                            imagePath: 'assets/images/TimeMachine_50px.png',
                            label: 'History',
                            imageSize: iconSize * 0.87,
                            paddingSize: paddingSize,
                            textSize: textSize,
                            isPopup: true,
                            popupMenu: buildPopupMenuButton(
                                RoutesName.viewHistory,
                                'assets/images/TimeMachine_50px.png',
                                _selectedDeviceIndex!,
                                'History',
                                state.filteredDevices),
                          ),
                          _buildDrawerItem(
                            imagePath: 'assets/images/ComboChart_48px.png',
                            label: 'Reports',
                            imageSize: iconSize * 0.87,
                            paddingSize: paddingSize,
                            textSize: textSize,
                            isPopup: true,
                            popupMenu: buildPopupMenuButton(
                                RoutesName.reportTypes,
                                'assets/images/ComboChart_48px.png',
                                _selectedDeviceIndex!,
                                'Reports',
                                state.filteredDevices),
                          ),
                          _buildDrawerItem(
                            imagePath: 'assets/images/Lock_48px.png',
                            label: 'Immobilizer',
                            imageSize: iconSize * 0.87,
                            paddingSize: paddingSize,
                            textSize: textSize,
                            onTap: () => showDeviceCommandsPicker(
                                int.tryParse(device.id?.toString() ?? '0') ?? 0,
                                context.read<GetDevicesListCubit>()),
                          ),
                          _buildDrawerItem(
                            imagePath: 'assets/images/Pressure_40px.png',
                            label: 'Sensors',
                            imageSize: iconSize * 0.87,
                            paddingSize: paddingSize,
                            textSize: textSize,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.vehicleSensorData,
                                  arguments: {
                                    'vehicleSensorsData': device.sensors,
                                    'vehicleName':
                                        device.name?.toString() ?? 'Unknown',
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<GetDevicesListCubit>()),
            BlocProvider.value(value: context.read<GetDeviceGroupCubit>()),
          ],
          child: BlocListener<GetDeviceGroupCubit, GetDeviceGroupState>(
            listener: (context, state) {
              if (state is GetDeviceGroupLoaded && state.model != null) {
                context
                    .read<GetDevicesListCubit>()
                    .updateGroupModel(state.model);
              }
            },
            child: BlocBuilder<GetDevicesListCubit, GetDevicesListState>(
              builder: (context, state) {
                if (state.showLoading &&
                    (state.model == null ||
                        state.model!.items == null ||
                        state.model!.items!.isEmpty)) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Row(
                            children: List.generate(
                              8,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  width: 14.w,
                                  height: 9.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 0.5.h),
                                child: Container(
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    BlocBuilder<GetDevicesListCubit, GetDevicesListState>(
                      buildWhen: (previous, current) =>
                          previous.filterStatus != current.filterStatus ||
                          previous.groupFilter != current.groupFilter ||
                          previous.model != current.model ||
                          previous.isLoading != current.isLoading,
                      builder: (context, state) {
                        final cubit = context.read<GetDevicesListCubit>();
                        final filters = [
                          {
                            'status': 'all',
                            'count': cubit.getCountForStatus('all'),
                            'label': 'All'
                          },
                          {
                            'status': 'running',
                            'count': cubit.getCountForStatus('running'),
                            'label': 'Driving'
                          },
                          {
                            'status': 'stopped',
                            'count': cubit.getCountForStatus('stopped'),
                            'label': 'Stopped'
                          },
                          {
                            'status': 'idle',
                            'count': cubit.getCountForStatus('idle'),
                            'label': 'Idle'
                          },
                          {
                            'status': 'offline',
                            'count': cubit.getCountForStatus('offline'),
                            'label': 'Offline'
                          },
                          {
                            'status': 'nodata',
                            'count': cubit.getCountForStatus('nodata'),
                            'label': 'No Data'
                          },
                          {
                            'status': 'expired',
                            'count': cubit.getCountForStatus('expired'),
                            'label': 'Expired'
                          },
                        ];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Row(
                            children: filters
                                .map((filter) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: FilterOption(
                                        statusCount: filter['count'] as int,
                                        status: filter['status'] as String,
                                        onTap: (status) {
                                          cubit.setFilter(status);
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: searchController,
                        onChanged: (keyword) {
                          context
                              .read<GetDevicesListCubit>()
                              .updateSearchKeyword(keyword);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by vehicle',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search, color: Colors.grey[500]),
                              SizedBox(width: 2.w),
                              IconButton(
                                icon: Icon(Icons.filter_list,
                                    color: Colors.grey[500]),
                                onPressed: () =>
                                    _showGroupFilterDialog(context),
                              ),
                            ],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1976D2), width: 2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Group : ",
                                  style: TextStyle(
                                    fontSize: 13.px,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                TextSpan(
                                  text: context
                                      .read<GetDevicesListCubit>()
                                      .currentGroupName,
                                  style: TextStyle(
                                    fontSize: 12.px,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          BlocBuilder<GetDevicesListCubit, GetDevicesListState>(
                        buildWhen: (previous, current) =>
                            previous.filteredDevices !=
                                current.filteredDevices ||
                            previous.isLoading != current.isLoading ||
                            previous.showLoading != current.showLoading ||
                            previous.groupFilter != current.groupFilter ||
                            previous is GetDevicesListError !=
                                current is GetDevicesListError,
                        builder: (context, state) {
                          if (state.filteredDevices.isNotEmpty) {
                            return ListView.builder(
                              itemCount: state.filteredDevices.length,
                              itemBuilder: (context, index) {
                                final device = state.filteredDevices[index];
                                vehicleCurrentStatusFromAPI =
                                    device.online?.toString().toLowerCase() ??
                                        '';
                                final vehicleTime =
                                    device.time?.toString().toLowerCase() ?? '';
                                final deviceId = device.id?.toString() ?? '0';
                                sensorsData = device.sensors as List<dynamic>?;
                                processSensorData(sensorsData, deviceId);
                                setVehicleStatusAndColors(
                                    vehicleCurrentStatusFromAPI, vehicleTime);
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  child: Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          context
                                              .read<GetDevicesListCubit>()
                                              .fetchDevicesList(
                                                  isRefresh: true,
                                                  context: context);
                                          _searchFocusNode.unfocus();
                                          setState(() {
                                            _selectedDeviceIndex = index;
                                            if (_selectedDeviceIndex! <
                                                state.filteredDevices.length) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                if (!(_scaffoldKey.currentState
                                                        ?.isEndDrawerOpen ??
                                                    false)) {
                                                  _scaffoldKey.currentState
                                                      ?.openEndDrawer();
                                                }
                                              });
                                            } else {
                                              _selectedDeviceIndex = null;
                                            }
                                          });
                                        },
                                        child: DeviceInfoCardStyle(
                                          name: device.name?.toString() ??
                                              'Unknown',
                                          groupTitle: 'No Group',
                                          speed:
                                              device.speed?.toString() ?? '0',
                                          vehicleStatus: vehicleStatus,
                                          stopTime: device.online
                                                      ?.toString()
                                                      .toLowerCase() ==
                                                  'online'
                                              ? ''
                                              : device.stopDuration ?? '0',
                                          lastUpdateTime:
                                              device.time?.toString() ?? 'N/A',
                                          iconPathfromApi:
                                              device.path?.toString() ?? '',
                                          immobilizerValue:
                                              device.param?.blocked == "true" ||
                                                      device.param?.out1 ==
                                                          'true'
                                                  ? true
                                                  : false,
                                          batteryVoltage:
                                              device.param?.sat ?? "",
                                          backgroundColor: mainBoxbgColor,
                                          vehicleStatusColor:
                                              vehicleStatusColor,
                                          keyColor:
                                              device.param?.ignition == "true"
                                                  ? Colors.green
                                                  : Colors.red,
                                          batteryCharging:
                                              device.param?.charge ?? "",
                                          deviceLat: double.tryParse(
                                                  device.lat?.toString() ??
                                                      '0') ??
                                              0.0,
                                          deviceLng: double.tryParse(
                                                  device.lng?.toString() ??
                                                      '0') ??
                                              0.0,
                                          address: device.addr.toString(),
                                          network: device.param?.rssi == "1"
                                              ? "20%"
                                              : device.param?.rssi == "2"
                                                  ? "40%"
                                                  : device.param?.rssi == "3"
                                                      ? "60%"
                                                      : device.param?.rssi ==
                                                              "4"
                                                          ? "80%"
                                                          : "100%",
                                        ),
                                      ),
                                      if (device.param?.blocked == "true" ||
                                          device.param?.out1 == '1') ...[
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3.h),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.grey[900]!
                                                .withOpacity(0.6),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.lock,
                                                size: 38, color: Colors.red),
                                          ),
                                        ),
                                        Positioned(
                                          top: 1.h,
                                          right: 4.w,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDeviceCommandsPicker(
                                                int.tryParse(deviceId) ?? 0,
                                                context.read<
                                                    GetDevicesListCubit>(),
                                              );
                                              context
                                                  .read<GetDevicesListCubit>()
                                                  .fetchDevicesList(
                                                      isRefresh: true,
                                                      context: context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3.w,
                                                  vertical: 0.8.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1976D2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.lock_open,
                                                      size: 16,
                                                      color: Colors.white),
                                                  SizedBox(width: 1.w),
                                                  Text(
                                                    'UNLOCK',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] else if (device.time == "Expired") ...[
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3.h),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.grey[900]!
                                                .withOpacity(0.6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'EXPIRED',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          }

                          final message = state.filterStatus == 'all' &&
                                  state.groupFilter == null
                              ? 'No ungrouped vehicles available.'
                              : state.groupFilter == null
                                  ? 'No ungrouped vehicles are currently ${state.filterStatus == 'nodata' ? 'missing data' : state.filterStatus == 'expired' ? 'expired' : state.filterStatus}.'
                                  : 'No vehicles available in the selected group.';
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    state is GetDevicesListError
                                        ? Icons.error_outline
                                        : Icons.directions_car,
                                    size: 48,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state is GetDevicesListError
                                        ? state.errorMessage ??
                                            'Unable to load vehicles.'
                                        : message,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  if (state is GetDevicesListError)
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<GetDevicesListCubit>()
                                            .fetchDevicesList(
                                                isRefresh: true,
                                                context: context);
                                      },
                                      child: const Text(
                                        'Retry',
                                        style:
                                            TextStyle(color: Color(0xFF1976D2)),
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<GetDevicesListCubit>()
                                          .setGroupFilter(null, null);
                                      context
                                          .read<GetDevicesListCubit>()
                                          .setFilter('all');
                                    },
                                    child: const Text(
                                      'View Ungrouped Vehicles',
                                      style:
                                          TextStyle(color: Color(0xFF1976D2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String imagePath,
    required String label,
    double imageSize = 40,
    required double paddingSize,
    required double textSize,
    bool isPopup = false,
    PopupMenuButton<int>? popupMenu,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingSize * 3),
      child: InkWell(
        onTap: onTap,
        child: Column(
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
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
