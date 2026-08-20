import 'dart:async';
import 'dart:developer';
import 'package:autotelematic_new_app/cubit/get_devices_list_state.dart';
import 'package:autotelematic_new_app/model/get_device_list_model.dart';
import 'package:autotelematic_new_app/model/get_device_group_model.dart';
import 'package:autotelematic_new_app/repository/get_devices_list_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class GetDevicesListCubit extends Cubit<GetDevicesListState> with WidgetsBindingObserver {
  final GetDevicesListRepository repository;
  GetDevicesListModel? _lastValidModel;
  GetDeviceGroupModel? _lastValidGroupModel;
  BuildContext context;
  String currentFilter = 'all';
  String? currentGroupFilter = 'all';
  String? currentGroupName = 'All';
  String searchKeyword = '';
  Timer? _timer;

  GetDevicesListCubit(this.repository, this.context)
      : super(GetDevicesListInitial()) {
    WidgetsBinding.instance.addObserver(this);
    startPeriodicUpdates(context: context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      stopPeriodicUpdates();
    } else if (state == AppLifecycleState.resumed) {
      // Delay restart to allow network stabilization
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) startPeriodicUpdates(context: context);
      });
    }
  }

  void startPeriodicUpdates({required BuildContext context}) {
    _timer?.cancel();
    // Initial fetch immediately
    fetchDevicesList(isPeriodic: true, context: context);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchDevicesList(isPeriodic: true, context: context);
    });
  }

  void stopPeriodicUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  void setFilter(String status) {
    if (currentFilter != status) {
      currentFilter = status;
      if (_lastValidModel != null && _lastValidModel!.items != null) {
        emitFilteredList(_lastValidModel!);
      } else {
        emit(GetDevicesListLoaded(
          model: _lastValidModel,
          filteredDevices: [],
          filterStatus: currentFilter,
          groupFilter: currentGroupFilter,
          groupName: currentGroupName,
        ));
      }
    }
  }

  void setGroupFilter(String? groupId, String? groupName) {
    if (currentGroupFilter != groupId || currentGroupName != groupName) {
      currentGroupFilter = groupId;
      currentGroupName = groupName;
      if (_lastValidModel != null && _lastValidModel!.items != null) {
        currentFilter = 'all';
        emitFilteredList(_lastValidModel!);
      } else {
        emit(GetDevicesListLoaded(
          model: _lastValidModel,
          filteredDevices: [],
          filterStatus: currentFilter,
          groupFilter: currentGroupFilter,
          groupName: currentGroupName,
        ));
      }
    }
  }

  void updateGroupModel(GetDeviceGroupModel? groupModel) {
    _lastValidGroupModel = groupModel;
    currentGroupFilter = 'all';
    currentGroupName = 'All';
    if (_lastValidModel != null && _lastValidModel!.items != null) {
      emitFilteredList(_lastValidModel!);
    }
  }

  void updateSearchKeyword(String keyword) {
    searchKeyword = keyword;
    if (_lastValidModel != null && _lastValidModel!.items != null) {
      emitFilteredList(_lastValidModel!);
    } else {
      emit(GetDevicesListLoaded(
        model: _lastValidModel,
        filteredDevices: [],
        filterStatus: currentFilter,
        groupFilter: currentGroupFilter,
        groupName: currentGroupName,
      ));
    }
  }

  Future<void> fetchDevicesList(
      {bool isRefresh = false, bool isPeriodic = false, required BuildContext context}) async {
    final bool hasValidData =
        _lastValidModel != null && _lastValidModel!.items != null && _lastValidModel!.items!.isNotEmpty;
    final bool showLoading = !isPeriodic && (isRefresh || !hasValidData);

    final currentFilteredDevices = state.filteredDevices;

    if (showLoading) {
      emit(GetDevicesListLoading(
        previousModel: _lastValidModel,
        showLoading: true,
        filteredDevices: currentFilteredDevices,
        filterStatus: currentFilter,
        groupFilter: currentGroupFilter,
        groupName: currentGroupName,
      ));
    }

    try {
      final data = await repository.getDevicesListApi(dialogContext: context);
      log("Parsed Data: ${data?.toJson()}");
      if (data != null && data.items != null && data.items!.isNotEmpty) {
        _lastValidModel = data;
        emitFilteredList(data);
      } else {
        log("No valid data or empty items");
        emit(GetDevicesListLoaded(
          model: _lastValidModel,
          filteredDevices: hasValidData ? currentFilteredDevices : [],
          filterStatus: currentFilter,
          groupFilter: currentGroupFilter,
          groupName: currentGroupName,
        ));
      }
    } catch (e) {
      log("Error in fetchDevicesList: $e");
      
      // If we already have data, don't show full screen error (silent error)
      if (hasValidData) {
        log("Silent failure: Keeping existing data due to network error.");
        return;
      }

      String userFriendlyMessage = e.toString();
      if (userFriendlyMessage.contains('unserialize()')) {
        userFriendlyMessage = 'Server is synchronizing data. Please try again in a moment.';
      } else if (userFriendlyMessage.contains('Exception:')) {
        userFriendlyMessage = userFriendlyMessage.replaceAll('Exception:', '').trim();
      } else if (userFriendlyMessage.contains('SocketException') || userFriendlyMessage.contains('ClientException')) {
        userFriendlyMessage = 'No internet connection. Please check your network.';
      }
      
      emit(GetDevicesListError(
        message: userFriendlyMessage,
        previousModel: _lastValidModel,
        filteredDevices: hasValidData ? currentFilteredDevices : [],
        filterStatus: currentFilter,
        groupFilter: currentGroupFilter,
        groupName: currentGroupName,
      ));
    }
  }

  void emitFilteredList(GetDevicesListModel data) {
    List<Item> filteredDevices = data.items ?? [];

    // If there is a search keyword, filter from the full list and ignore status/group filters
    if (searchKeyword.isNotEmpty) {
      filteredDevices = filteredDevices.where((device) {
        final deviceName = device.name?.toString().toLowerCase() ?? '';
        return deviceName.contains(searchKeyword.toLowerCase());
      }).toList();
    } else {
      // Apply status filter only when no search is active
      switch (currentFilter) {
        case 'all':
          break;
        case 'running':
          filteredDevices = filteredDevices.where((item) => item.online == "online").toList();
          break;
        case 'stopped':
          filteredDevices = filteredDevices.where((item) => item.online == "ack").toList();
          break;
        case 'idle':
          filteredDevices = filteredDevices.where((item) => item.online == "engine").toList();
          break;
        case 'offline':
          filteredDevices = filteredDevices
              .where((item) =>
          item.online == "offline" &&
              item.time?.toLowerCase() != "not connected" &&
              item.time?.toLowerCase() != "expired")
              .toList();
          break;
        case 'nodata':
          filteredDevices = filteredDevices
              .where((item) => item.online == "offline" && item.time?.toLowerCase() == "not connected")
              .toList();
          break;
        case 'expired':
          filteredDevices = filteredDevices
              .where((item) => item.online == "offline" && item.time?.toLowerCase() == "expired")
              .toList();
          break;
        case 'parked':
          filteredDevices = filteredDevices.where((item) => item.online == "black").toList();
          break;
        default:
          filteredDevices = filteredDevices
              .where((item) =>
          item.online != "ack" &&
              item.online != "online" &&
              item.online != "offline" &&
              item.online != "engine" &&
              item.online != "black")
              .toList();
          break;
      }

      // Apply group filter only when no search is active
      if (currentGroupFilter != 'all' && currentGroupFilter != null && _lastValidGroupModel != null) {
        final selectedGroup = _lastValidGroupModel!.items?.firstWhere(
              (group) => group.id.toString() == currentGroupFilter,
          orElse: () => GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []),
        ) ?? GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []);
        if (selectedGroup.id != -1) {
          final groupDeviceIds = selectedGroup.items?.map((item) => item.id).toSet() ?? <int?>{};
          filteredDevices = filteredDevices.where((device) => groupDeviceIds.contains(device.id)).toList();
        } else {
          filteredDevices = [];
        }
      } else if (currentGroupFilter == null && _lastValidGroupModel != null) {
        final ungroupedGroup = _lastValidGroupModel?.items?.firstWhere(
              (group) => group.title?.toLowerCase() == 'ungrouped',
          orElse: () => GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []),
        );
        if (ungroupedGroup != null && ungroupedGroup.id != -1) {
          final groupDeviceIds = ungroupedGroup.items?.map((item) => item.id).toSet() ?? <int?>{};
          filteredDevices = filteredDevices.where((device) => groupDeviceIds.contains(device.id)).toList();
        }
      }
    }

    emit(GetDevicesListLoaded(
      model: data,
      filteredDevices: filteredDevices,
      filterStatus: currentFilter,
      groupFilter: currentGroupFilter,
      groupName: currentGroupName,
    ));
  }

  int getCountForStatus(String status) {
    if (_lastValidModel == null || _lastValidModel!.items == null) return 0;
    var items = _lastValidModel!.items!;

    // Apply group filter for counts
    if (currentGroupFilter != 'all' && currentGroupFilter != null && _lastValidGroupModel != null) {
      final selectedGroup = _lastValidGroupModel!.items?.firstWhere(
            (group) => group.id.toString() == currentGroupFilter,
        orElse: () => GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []),
      ) ?? GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []);
      if (selectedGroup.id != -1) {
        final groupDeviceIds = selectedGroup.items?.map((item) => item.id).toSet() ?? <int?>{};
        items = items.where((device) => groupDeviceIds.contains(device.id)).toList();
      } else {
        items = [];
      }
    } else if (currentGroupFilter == null && _lastValidGroupModel != null) {
      final ungroupedGroup = _lastValidGroupModel?.items?.firstWhere(
            (group) => group.title?.toLowerCase() == 'ungrouped',
        orElse: () => GetDeviceGroupModelItem(id: -1, title: 'Empty', items: []),
      );
      if (ungroupedGroup != null && ungroupedGroup.id != -1) {
        final groupDeviceIds = ungroupedGroup.items?.map((item) => item.id).toSet() ?? <int?>{};
        items = items.where((device) => groupDeviceIds.contains(device.id)).toList();
      }
    }

    switch (status) {
      case 'all':
        return items.length;
      case 'running':
        return items.where((item) => item.online == "online").length;
      case 'stopped':
        return items.where((item) => item.online == "ack").length;
      case 'idle':
        return items.where((item) => item.online == "engine").length;
      case 'offline':
        return items
            .where((item) =>
        item.online == "offline" &&
            item.time?.toLowerCase() != "not connected" &&
            item.time?.toLowerCase() != "expired")
            .length;
      case 'nodata':
        return items
            .where((item) => item.online == "offline" && item.time?.toLowerCase() == "not connected")
            .length;
      case 'expired':
        return items
            .where((item) => item.online == "offline" && item.time?.toLowerCase() == "expired")
            .length;
      case 'parked':
        return items.where((item) => item.online == "black").length;
      default:
        return items
            .where((item) =>
        item.online != "ack" &&
            item.online != "online" &&
            item.online != "offline" &&
            item.online != "engine" &&
            item.online != "black")
            .length;
    }
  }

  void updateFilteredDevices(List<Item> filteredList) {
    emit(GetDevicesListLoaded(
      model: _lastValidModel,
      filteredDevices: filteredList,
      filterStatus: currentFilter,
      groupFilter: currentGroupFilter,
      groupName: currentGroupName,
    ));
  }

  String formatDuration(int seconds) {
    if (seconds < 60) return "$seconds sec";
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    if (minutes < 60) {
      return seconds > 0 ? "$minutes min $seconds sec" : "$minutes min";
    }
    int hours = minutes ~/ 60;
    minutes = minutes % 60;
    if (hours < 24) {
      String hr = "$hours hr";
      String min = minutes > 0 ? " $minutes min" : "";
      return seconds > 0 ? "$hr$min $seconds sec" : min.isNotEmpty ? "$hr$min" : hr;
    }
    int days = hours ~/ 24;
    hours = hours % 24;
    String d = "$days d";
    String h = hours > 0 ? " $hours h" : "";
    String m = minutes > 0 ? " $minutes m" : "";
    return seconds > 0 ? "$d$h$m $seconds s" : m.isNotEmpty ? "$d$h$m" : h.isNotEmpty ? "$d$h" : d;
  }

  int parseStopDuration(String duration) {
    final regex = RegExp(r'((\d+)h)?\s*((\d+)min)?\s*((\d+)s)?');
    final match = regex.firstMatch(duration);

    if (match == null) return 0;

    int hours = int.tryParse(match.group(2) ?? '0') ?? 0;
    int minutes = int.tryParse(match.group(4) ?? '0') ?? 0;
    int seconds = int.tryParse(match.group(6) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    stopPeriodicUpdates();
    return super.close();
  }
}