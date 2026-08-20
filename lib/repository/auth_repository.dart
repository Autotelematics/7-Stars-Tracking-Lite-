import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final NetworkAPI networkAPI = NetworkAPI();

  Future<UserLoginData> signinAPI(Map<String, dynamic> data) async {
    try {
      Response response = await networkAPI.sendRequest.post(
        '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.loginEndPoint}',
        data: data,
      );

      if (response.statusCode == 200) {
        final user = UserLoginData.fromJson(response.data);

        return user;
      } else {
        final errorMessage = response.data['message'] ??
            response.data['error'] ??
            'Failed to sign in: ${response.statusMessage}';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          e.response?.data['error'] ??
          'An error occurred: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
