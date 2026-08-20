part of 'device_history_cubit.dart';

class DeviceHistoryState {
  const DeviceHistoryState();
}

class DeviceHistoryInitial extends DeviceHistoryState {}

class DeviceHistoryLoading extends DeviceHistoryState {}

class DeviceHistoryRefresh extends DeviceHistoryState {}

class DeviceHistoryError extends DeviceHistoryState {
  String message;
  DeviceHistoryError(this.message);
}

class DeviceHistoryLoadingComplete extends DeviceHistoryState {
  DeviceHistoryModel deviceHistoryModel;
  DeviceHistoryLoadingComplete(this.deviceHistoryModel);
}
