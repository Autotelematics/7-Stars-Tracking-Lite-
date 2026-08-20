import 'package:autotelematic_new_app/cubit/get_device_status_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_status_state.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/get_device_status_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'customreportandhistory.dart';

class VehicleListForHistory extends StatefulWidget {
  const VehicleListForHistory({super.key});

  @override
  State<VehicleListForHistory> createState() => _VehicleListForHistoryState();
}

class _VehicleListForHistoryState extends State<VehicleListForHistory> {
  List<Item> deviceDataListResult = [], searchResult = [];
  String filterStatus = 'all';
  bool isSearchResult = false;
  DateFormat dateFormat = DateFormat("yy-MM-dd");
  Color color = Colors.grey;

  void runSearchFilter(String keyword, List<Item> devices) {
    searchResult.clear();
    if (keyword.isEmpty) {
      isSearchResult = false;
      searchResult.addAll(devices);
    } else {
      isSearchResult = true;
      searchResult.addAll(devices.where((vehicle) =>
          vehicle.name.toLowerCase().contains(keyword.toLowerCase())));
    }
  }

  Future<void> showDatePickerDialog(
      BuildContext context, String route, String deviceName, int deviceId) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [CustomeHistoryDateTimePicker(deviceName, deviceId, route)],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch fresh data, but loading UI depends on showLoading
    context.read<GetDeviceStatusCubit>().fetchDeviceStatus(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_outlined, size: 2.5.h, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19.sp)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            SizedBox(height: 1.h),
            TextField(
              onChanged: (value) {
                runSearchFilter(value, deviceDataListResult);
                setState(() {}); // Trigger UI rebuild
              },
              decoration: InputDecoration(
                hintText: 'Search vehicle',
                hintStyle: TextStyle(color: Colors.grey[500]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.search, color: Colors.grey[500]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 1.h),
                  BlocBuilder<GetDeviceStatusCubit, GetDeviceStatusState>(
                    builder: (context, state) {
                      // Check if there's valid data
                      final bool hasValidData = state.model != null &&
                          (state.model!.totalCount > 0 || state.model!.items.isNotEmpty);

                      // Populate deviceDataListResult
                      if (hasValidData) {
                        if (!isSearchResult) {
                          searchResult
                            ..clear()
                            ..addAll(state.model!.items);
                        }
                        deviceDataListResult
                          ..clear()
                          ..addAll(searchResult);
                      }

                      // Show error if present
                      if (state is GetDeviceStatusError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: ${state.errorMessage}',
                                  style: TextStyle(fontSize: 16.sp)),
                              SizedBox(height: 2.h),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<GetDeviceStatusCubit>().fetchDeviceStatus(context: context),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Show data UI if valid data is available
                      if (hasValidData && deviceDataListResult.isNotEmpty) {
                        return Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => context
                                .read<GetDeviceStatusCubit>()
                                .fetchDeviceStatus(isRefresh: true,context: context),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: deviceDataListResult.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 6.h,
                                              width: 5.h,
                                              child: Image.network(
                                                ApiEndpointUrls.baseImgURL + deviceDataListResult[index].icon,
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              deviceDataListResult[index].name.length>20?"${deviceDataListResult[index].name.substring(0,20)}...":deviceDataListResult[index].name,
                                              style: TextStyle(fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton(
                                          position: PopupMenuPosition.under,
                                          color: Colors.white,
                                          onSelected: (value) {
                                            final now = DateTime.now();
                                            final formatter = DateFormat('yyyy-MM-dd');
                                            var toDate = formatter.format(now);
                                            var fromDate = toDate;
                                            const fromTime = '00:00:00';
                                            const toTime = '23:59:59';
                                            switch (value) {
                                              case 0:
                                                // Today
                                                break;
                                              case 1:
                                                fromDate = formatter.format(now.subtract(const Duration(days: 1)));
                                                toDate = fromDate;
                                                break;
                                              case 7:
                                                fromDate = formatter.format(now.subtract(const Duration(days: 6)));
                                                break;
                                              case 2:
                                                showDatePickerDialog(
                                                  context,
                                                  'playroutonmap',
                                                  deviceDataListResult[index].name,
                                                  deviceDataListResult[index].id,
                                                );
                                                return;
                                            }
                                            Navigator.pushNamed(
                                              context,
                                              RoutesName.viewHistory,
                                              arguments: DeviceDataForReportsAndHistory(
                                                deviceId: deviceDataListResult[index].id,
                                                deviceTitle: deviceDataListResult[index].name,
                                                fromDate: fromDate,
                                                toDate: toDate,
                                                fromTime: fromTime,
                                                toTime: toTime,
                                              ),
                                            );
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(value: 0, child: Text('Today')),
                                            PopupMenuItem(value: 1, child: Text('Yesterday')),
                                            PopupMenuItem(value: 7, child: Text('7 Days')),
                                            PopupMenuItem(value: 2, child: Text('Custom Date')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }

                      // Show loading only if showLoading is true and no valid data
                      if (state.isLoading && state.showLoading && !hasValidData) {
                        return Column(
                          children: [
                            AppTheme.loadingImage,
                            const SizedBox(height: 5),
                            const Text('Loading...'),
                          ],
                        );
                      }

                      // Default: show empty state
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No data available', style: TextStyle(fontSize: 16.sp)),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<GetDeviceStatusCubit>().fetchDeviceStatus(context: context),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}