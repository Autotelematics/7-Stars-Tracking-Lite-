import 'package:autotelematic_new_app/model/get_device_status_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Base state for device status management.
abstract class GetDeviceStatusState {
  final bool isLoading;
  final GetDeviceStatusModel? model;
  final String? errorMessage;
  final bool showLoading;

  GetDeviceStatusState({
    required this.isLoading,
    this.model,
    this.errorMessage,
    required this.showLoading,
  });
}

/// Initial state for device status.
class GetDeviceStatusInitial extends GetDeviceStatusState {
  GetDeviceStatusInitial()
      : super(isLoading: false, model: null, showLoading: true);
}

/// Loading state, optionally showing previous data.
class GetDeviceStatusLoading extends GetDeviceStatusState {
  GetDeviceStatusLoading({
    GetDeviceStatusModel? previousModel,
    required super.showLoading,
  }) : super(isLoading: true, model: previousModel);
}

/// Loaded state with device status data.
class GetDeviceStatusLoaded extends GetDeviceStatusState {
  GetDeviceStatusLoaded(GetDeviceStatusModel? model)
      : super(isLoading: false, model: model, showLoading: false);
}

/// Error state with an error message and optional previous data.
class GetDeviceStatusError extends GetDeviceStatusState {
  GetDeviceStatusError(String message, GetDeviceStatusModel? previousModel)
      : super(
            isLoading: false,
            model: previousModel,
            errorMessage: message,
            showLoading: false);
}

/// Navigation state for redirecting to a specific device's tracking screen.
class GetDeviceStatusNavigate extends GetDeviceStatusState {
  final int deviceId;
  final LatLng position;

  GetDeviceStatusNavigate({required this.deviceId, required this.position})
      : super(isLoading: false, model: null, showLoading: false);
}
