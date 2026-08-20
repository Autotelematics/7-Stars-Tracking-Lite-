import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/devicecommandlistmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class DeviceCommandListRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<List<DeviceCommandsListsModel>> getDeviceCommandsFromAPI(
      String userApiHashKey, String deviceID) async {
    List<DeviceCommandsListsModel> devicesCommandsList = [];
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDviceCommandsEndPoint}$userApiHashKey&device_id=$deviceID');
      devicesCommandsList = (response.data as List)
          .map((e) => DeviceCommandsListsModel.fromJson(e))
          .toList();

      return devicesCommandsList;
    } catch (e) {
      rethrow;
    }
  }
}
