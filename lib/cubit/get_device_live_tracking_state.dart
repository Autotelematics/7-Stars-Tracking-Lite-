
import 'package:autotelematic_new_app/model/get_device_live_tracking_model.dart';

abstract class GetDeviceLiveTrackingState {}

class GetDeviceLiveTrackingLoading extends GetDeviceLiveTrackingState {
  final bool showLoading;

  GetDeviceLiveTrackingLoading({required this.showLoading});
}

class GetDeviceLiveTrackingLoaded extends GetDeviceLiveTrackingState {}

class GetDeviceLiveTrackingError extends GetDeviceLiveTrackingState {
  final String? errorMessage;
  final GetDeviceLiveTrackingModel? model;

  GetDeviceLiveTrackingError({this.errorMessage, this.model});
}