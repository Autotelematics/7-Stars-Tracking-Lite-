import 'package:autotelematic_new_app/cubit/get_alert_list_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_alert_list_state.dart';
import 'package:autotelematic_new_app/cubit/get_devices_list_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_devices_list_state.dart';
import 'package:autotelematic_new_app/model/get_device_list_model.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class VehicleEventsScreen extends StatefulWidget {
  const VehicleEventsScreen({super.key});

  @override
  State<VehicleEventsScreen> createState() => _VehicleEventsScreenState();
}

class _VehicleEventsScreenState extends State<VehicleEventsScreen> {
  final ScrollController _scrollController = ScrollController();
  late GetAlertsListCubit _cubit;

  int? _selectedDeviceId;
  String? _selectedAlertType = "All";

  late final ValueNotifier<int?> _selectedDeviceIdNotifier;
  late final ValueNotifier<String?> _selectedAlertTypeNotifier;

  bool _shouldShowLoadMore(GetAlertsListState state) =>
      state.isLoading && !state.showLoading;

  @override
  void initState() {
    super.initState();
    _selectedDeviceIdNotifier = ValueNotifier<int?>(_selectedDeviceId);
    _selectedAlertTypeNotifier = ValueNotifier<String?>(_selectedAlertType);
    _scrollController.addListener(_loadMore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<GetAlertsListCubit>();

    // Initial fetch for alerts if needed
    if (_cubit.state.model == null || _cubit.state.model!.items.isEmpty) {
      _cubit.fetchAlertsList(dialogContext: context);
    }
    
    // Ensure devices are fetched
    final devicesCubit = context.read<GetDevicesListCubit>();
    if (devicesCubit.state.model == null) {
      devicesCubit.fetchDevicesList(context: context);
    }
  }

  void _loadMore() {
    final state = _cubit.state;
    if (_scrollController.position.extentAfter < 300 &&
        !_cubit.state.isLoading &&
        state.currentPage <= state.totalPages) {
      _cubit.fetchAlertsList(dialogContext: context);
    }
  }

  void _applyFilters() {
    _cubit.setDeviceIdFilter(_selectedDeviceId);
    // "All" means show all types (null for backend)
    _cubit.setAlertTypeFilter(
        _selectedAlertType == "All" ? null : _selectedAlertType);
    _cubit.fetchAlertsList(isRefresh: true, dialogContext: context);
  }

  void _clearFilters() {
    final alertTypeList = context.read<GetAlertsListCubit>().alertTypeList;
    setState(() {
      _selectedDeviceId = null;
      _selectedAlertType =
      alertTypeList.isNotEmpty ? alertTypeList.first : null;
      _selectedDeviceIdNotifier.value = _selectedDeviceId;
      _selectedAlertTypeNotifier.value = _selectedAlertType;
    });
    _cubit.clearFilters();
    _cubit.fetchAlertsList(isRefresh: true, dialogContext: context);
  }

  Widget _buildFilterBar(List<Item> devices, List<String> alertTypeList,
      Map<String, int> alertTypeCounts) {
    // Shimmer on top filter bar when devices are loading
    if (devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Crash prevention: Ensure selected value exists in the current list
    if (_selectedAlertType != null &&
        !alertTypeList.contains(_selectedAlertType)) {
      _selectedAlertType = "All";
      // Update notifier immediately to avoid crash in current build
      _selectedAlertTypeNotifier.value = "All";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    valueListenable: _selectedDeviceIdNotifier,
                    isExpanded: true,
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.black87),
                    ),
                    hint: const Text(
                      "Select Vehicle",
                      style: TextStyle(
                        color: Color.fromARGB(255, 6, 6, 6),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    items: devices
                        .map((e) => e.id).toSet().map((id) => devices.firstWhere((d) => d.id == id))
                        .map(
                          (device) => DropdownItem<int>(
                        value: device.id,
                        child: Text(
                          device.name ?? 'Device ${device.id}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDeviceId = val;
                        _selectedDeviceIdNotifier.value = val;
                      });
                      // Auto-apply filter when vehicle changes for real-time updates
                      _applyFilters();
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      maxHeight: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 131, 131, 131),
                      width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    valueListenable: _selectedAlertTypeNotifier,
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.black87),
                    ),
                    isExpanded: true,
                    hint: const Text(
                      "Alert Type",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    items: alertTypeList.toSet().toList()
                        .map(
                          (type) => DropdownItem<String>(
                        value: type,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: ' (${alertTypeCounts[type] ?? 0})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: type == 'All'
                                      ? Colors.blue
                                      : Colors.green,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedAlertType = val;
                        _selectedAlertTypeNotifier.value = val;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      maxHeight: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              minimumSize: const Size(0, 44),
            ),
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Card(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  title: Container(
                    width: 100,
                    height: 16,
                    color: Colors.white,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(List<int> alertIds) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alerts'),
        content: Text(
            'Are you sure you want to delete ${alertIds.length} alert${alertIds.length > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _cubit.deleteAlerts(alertIds);
      if (context.mounted) {
        final state = _cubit.state;
        if (state is GetAlertsListLoaded) {
          CommonUtils.toastMessage(
              '${alertIds.length} alert${alertIds.length > 1 ? 's' : ''} deleted successfully');
        } else if (state is GetAlertsListError) {
          CommonUtils.toastMessage(
              state.errorMessage ?? 'Failed to delete alerts');
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Alerts Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or refresh the list',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cubit.fetchAlertsList(
                  isRefresh: true, dialogContext: context),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Alerts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _cubit.fetchAlertsList(isRefresh: true, dialogContext: context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alerts'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _cubit.fetchAlertsList(
                  isRefresh: true, dialogContext: context),
              icon: const Icon(Icons.refresh, color: Colors.green),
              tooltip: "Refresh",
            ),
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, color: Colors.red),
              tooltip: "Clear Filters",
            ),
            BlocBuilder<GetAlertsListCubit, GetAlertsListState>(
              builder: (context, state) {
                if (state.selectedAlertIds.isNotEmpty) {
                  return IconButton(
                    onPressed: () =>
                        _showDeleteConfirmationDialog(state.selectedAlertIds),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Delete Selected",
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<GetAlertsListCubit, GetAlertsListState>(
          listener: (context, state) {
            // No action needed here, _buildFilterBar handles self-healing
          },
          child: BlocBuilder<GetAlertsListCubit, GetAlertsListState>(
            builder: (context, state) {
              final cubit = context.watch<GetAlertsListCubit>();
              final alertTypeList = cubit.alertTypeList;
              final alertTypeCounts = cubit.alertTypeCounts;

              return BlocBuilder<GetDevicesListCubit, GetDevicesListState>(
                builder: (context, devicesState) {
                  final List<Item> devices = devicesState.model?.items ?? [];
                  final filterBar =
                      _buildFilterBar(devices, alertTypeList, alertTypeCounts);

                  if (state.isLoading && state.showLoading) {
                    return Column(
                      children: [
                        filterBar,
                        Expanded(child: _buildLoadingShimmer()),
                      ],
                    );
                  }

                if (state is GetAlertsListError && state.model == null) {
                  return Column(
                    children: [
                      filterBar,
                      Expanded(
                        child: Center(
                            child: Text(state.errorMessage ??
                                'Something went wrong')),
                      ),
                    ],
                  );
                }

                final model = state.model;
                if (model != null && model.items.isNotEmpty) {
                  final alertsList = model.items;

                  return Column(
                    children: [
                      filterBar,
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: alertsList.length +
                              (_shouldShowLoadMore(state) ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < alertsList.length) {
                              final alert = alertsList[index];
                              return GestureDetector(
                                key: ValueKey(alert.id),
                                onTap: () {
                                  if (state.selectedAlertIds.isNotEmpty) {
                                    _cubit.toggleSelection(alert.id);
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      RoutesName.eventOnMap,
                                      arguments: alert,
                                    );
                                  }
                                },
                                onLongPress: () =>
                                    _cubit.toggleSelection(alert.id),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 0),
                                  child: Card(
                                    elevation: state.selectedAlertIds
                                            .contains(alert.id)
                                        ? 4.0
                                        : 1.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: state.selectedAlertIds
                                              .contains(alert.id)
                                          ? const BorderSide(
                                              color: Colors.red, width: 2.0)
                                          : BorderSide.none,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        title: Text(alert.deviceName),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(alert.message,
                                                style: const TextStyle(
                                                    color: Colors.red)),
                                            const SizedBox(height: 4),
                                            Text(
                                                alert.time
                                                        ?.toLocal()
                                                        .toString() ??
                                                    'No time available',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                        leading: const Icon(
                                            Icons.notifications_none_outlined,
                                            color: Colors.red),
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.red),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Loading more...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    filterBar,
                    Expanded(child: _buildEmptyState()),
                  ],
                );
              },
            );
          },
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _cubit.clearSelection();
    _scrollController.dispose();
    _selectedDeviceIdNotifier.dispose();
    _selectedAlertTypeNotifier.dispose();
    super.dispose();
  }
}
