import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/devicehistorymodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class DeviceHistoryRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<DeviceHistoryModel> getDeviceHisFromAPI(
      String userApiHashKey, String deviceHistoryDateTime) async {
    try {
      if (userApiHashKey.isEmpty) {
        throw Exception('User API hash key is empty');
      }
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDeviceHistoryEndPoint}$userApiHashKey$deviceHistoryDateTime');
      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }
      if (response.data == null || response.data.isEmpty) {
        throw Exception('Empty response from API');
      }
      return DeviceHistoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }
}
