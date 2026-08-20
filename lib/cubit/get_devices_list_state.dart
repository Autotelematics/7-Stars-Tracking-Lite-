import 'package:autotelematic_new_app/model/get_device_list_model.dart';

abstract class GetDevicesListState {
  final bool isLoading;
  final GetDevicesListModel? model;
  final String? errorMessage;
  final bool showLoading;
  final List<Item> filteredDevices;
  final String filterStatus;
  final String? groupFilter; // Add group filter
  final String? groupName; // Add group filter

  GetDevicesListState({
    required this.isLoading,
    this.model,
    this.errorMessage,
    required this.showLoading,
    this.filteredDevices = const [],
    this.filterStatus = 'all',
    this.groupFilter,
    this.groupName,
  });
}

class GetDevicesListInitial extends GetDevicesListState {
  GetDevicesListInitial()
      : super(
    isLoading: false,
    model: null,
    showLoading: true,
    filteredDevices: const [],
    filterStatus: 'all',
    groupFilter: null,
    groupName: null,
  );
}

class GetDevicesListLoading extends GetDevicesListState {
  GetDevicesListLoading({
    GetDevicesListModel? previousModel,
    required super.showLoading,
    super.filteredDevices,
    super.filterStatus,
    super.groupFilter,
    super.groupName,
  }) : super(
    isLoading: true,
    model: previousModel,
  );
}

class GetDevicesListLoaded extends GetDevicesListState {
  GetDevicesListLoaded({
    super.model,
    required super.filteredDevices,
    required super.filterStatus,
    super.groupFilter,
    super.groupName,
  }) : super(
    isLoading: false,
    showLoading: false,
  );
}

class GetDevicesListError extends GetDevicesListState {
  GetDevicesListError({
    required String message,
    GetDevicesListModel? previousModel,
    super.filteredDevices,
    super.filterStatus,
    super.groupFilter,
    super.groupName,
  }) : super(
    isLoading: false,
    model: previousModel,
    errorMessage: message,
    showLoading: false,
  );
}