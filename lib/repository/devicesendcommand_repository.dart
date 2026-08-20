import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/devicecommandresultmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class DeviceCommandResultRepository {
  NetworkAPI networkAPI = NetworkAPI();
  Future<DeviceCommandResultModel> getDeviceCommandRestulFromAPI(
      String hashkey, String deviceCommand, String deviceID) async {
    // print(
    //     '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.sendDeviceCommandEndPoint}$hashkey&device_id=$deviceID&type=$deviceCommand');
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.sendDeviceCommandEndPoint}$hashkey&device_id=$deviceID&type=$deviceCommand');

      return DeviceCommandResultModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
