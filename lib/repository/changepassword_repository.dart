import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/changepassowrdmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class ChangePasswordRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<ChangePasswordModel> changePasswordFromAPI(
      String userApiHashKey, String password) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.changePasswordEndPoint}$userApiHashKey&password=$password&password_confirmation=$password');

      return ChangePasswordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
