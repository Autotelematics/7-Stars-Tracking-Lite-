part of 'home_cubit.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadingRefresh extends HomeState {}

class HomeScreenIndex extends HomeState {}

class HomeNavigateToDeviceTracking extends HomeState {
  final int groupID;
  final int deviceID;

  HomeNavigateToDeviceTracking({required this.groupID, required this.deviceID});
}

class HomeError extends HomeState {
  String message;
  HomeError(this.message);
}

class HomeLoadingComplete extends HomeState {
  // List<DevicesModel> devicesModelList;
  // HomeLoadingComplete(this.devicesModelList);
}