part of 'device_command_list_cubit.dart';

class DeviceCommandListState {
  const DeviceCommandListState();
}

class DeviceCommandListInitial extends DeviceCommandListState {}

class DeviceCommandListLoading extends DeviceCommandListState {}

class DeviceCommandSelected extends DeviceCommandListState {}

class DeviceCommandsendComplete extends DeviceCommandListState {}

class DeviceCommandListError extends DeviceCommandListState {
  String message;
  DeviceCommandListError(this.message);
}

class DeviceCommandListLoadingComplete extends DeviceCommandListState {
  List<DeviceCommandsListsModel> deviceCommandsList;
  DeviceCommandListLoadingComplete(this.deviceCommandsList);
}
