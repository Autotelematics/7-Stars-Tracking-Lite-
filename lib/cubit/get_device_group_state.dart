import 'package:autotelematic_new_app/model/get_device_group_model.dart';

abstract class GetDeviceGroupState {
  final bool isLoading;
  final GetDeviceGroupModel? model;
  final String? errorMessage;
  final bool showLoading;
  final int currentPage;
  final int totalPages;

  GetDeviceGroupState({
    required this.isLoading,
    this.model,
    this.errorMessage,
    required this.showLoading,
    required this.currentPage,
    required this.totalPages,
  });
}

class GetDeviceGroupInitial extends GetDeviceGroupState {
  GetDeviceGroupInitial()
      : super(
    isLoading: false,
    model: null,
    showLoading: true,
    currentPage: 1,
    totalPages: 1,
  );
}

class GetDeviceGroupLoading extends GetDeviceGroupState {
  GetDeviceGroupLoading({
    required GetDeviceGroupModel? previousModel,
    required super.currentPage,
    required super.totalPages,
    required super.showLoading,
  }) : super(
    isLoading: true,
    model: previousModel,
  );
}

class GetDeviceGroupLoaded extends GetDeviceGroupState {
  GetDeviceGroupLoaded({
    required GetDeviceGroupModel model,
    required super.currentPage,
    required super.totalPages,
  }) : super(
    isLoading: false,
    showLoading: false,
    model: model,
  );
}

class GetDeviceGroupError extends GetDeviceGroupState {
  GetDeviceGroupError({
    required String message,
    required GetDeviceGroupModel? previousModel,
    required super.currentPage,
    required super.totalPages,
  }) : super(
    isLoading: false,
    model: previousModel,
    errorMessage: message,
    showLoading: false,
  );
}