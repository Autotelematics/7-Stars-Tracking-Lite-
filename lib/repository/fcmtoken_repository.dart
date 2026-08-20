import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/fcmmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class FcmTokenRepository {
  NetworkAPI networkAPI = NetworkAPI();
  Future<FCMTokenModel> fcmTokenSubmmissionApi(
      String hashkey, String fcmToken) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.fcmAlertTokenEndPoint}$hashkey&token=$fcmToken');
      // print(response);
      return FCMTokenModel.fromJson(response.data);
    } catch (e) {
      // print('Error is ' + e.toString());
      rethrow;
    }
  }
}
