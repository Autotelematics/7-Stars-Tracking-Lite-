import 'package:autotelematic_new_app/model/devicecommandlistmodel.dart';
import 'package:autotelematic_new_app/model/devicecommandresultmodel.dart';
import 'package:autotelematic_new_app/repository/commandlist_repository.dart';
import 'package:autotelematic_new_app/repository/devicesendcommand_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:bloc/bloc.dart';

part 'device_command_list_state.dart';

class DeviceCommandListCubit extends Cubit<DeviceCommandListState> {
  DeviceCommandListCubit() : super(DeviceCommandListInitial());

  List<DeviceCommandsListsModel> deviceCommandsList = [];
  DeviceCommandResultModel deviceCommandResultModel =
      DeviceCommandResultModel();
  DeviceCommandListRepository deviceCommandListRepository =
      DeviceCommandListRepository();
  DeviceCommandResultRepository deviceCommandResultRepository =
      DeviceCommandResultRepository();

  Future<void> fetchCommandsList(int deviceID) async {
    emit(DeviceCommandListLoading());
    String? userApiHashKey = await UserSessions.getUserApiHash();
    try {
      deviceCommandsList =
          await deviceCommandListRepository.getDeviceCommandsFromAPI(
        userApiHashKey.toString(),
        deviceID.toString(),
      );
      emit(DeviceCommandListLoadingComplete(deviceCommandsList));
    } catch (e) {
      emit(DeviceCommandListError('Error while fetching commands...'));
      rethrow;
    }
  }

  void deviceCommandSelected() {
    emit(DeviceCommandSelected());
  }

  Future<void> sendDeviceCommandtoAPI(
      String deviceCommand, String deviceID) async {
    if (deviceCommand == 'No Command') {
      emit(DeviceCommandListError('No command selected'));
      CommonUtils.toastMessage('Please select a command.');
      return;
    }
    emit(DeviceCommandListLoading());
    String? userApiHashKey = await UserSessions.getUserApiHash();
    try {
      deviceCommandResultModel =
          await deviceCommandResultRepository.getDeviceCommandRestulFromAPI(
        userApiHashKey.toString(),
        deviceCommand,
        deviceID,
      );
      CommonUtils.toastMessage('Command Sent.');
      emit(DeviceCommandsendComplete());
    } catch (e) {
      emit(DeviceCommandListError('Error to send command'));
    }
  }

  void reset() {
    emit(DeviceCommandListInitial());
  }
}
