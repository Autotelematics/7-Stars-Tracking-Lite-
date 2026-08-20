import 'package:autotelematic_new_app/model/devicedatamodel.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
part 'home_state.dart';
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(super.initialState);

  int groupIndex = 0;
  int deviceIndex = 0;
  List<DeviceData> deviceDataListwithGroupAndDeviceIndex = [];
  int homeCurrentIndex = 2;
  List<Map<String, dynamic>> immobiliserStatusList = [];

  void setHomeIndex(int index) {
    emit(HomeScreenIndex());
    homeCurrentIndex = index;
    emit(HomeLoadingRefresh());
  }

  bool? getImmobiliserStatus(String deviceId) {
    final statusEntry = immobiliserStatusList.firstWhere(
          (entry) => entry['deviceId'] == deviceId,
      orElse: () => {'immobiliserStatus': null},
    );
    return statusEntry['immobiliserStatus'] as bool?;
  }

}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color? color;
}