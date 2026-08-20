import 'dart:convert';
import 'dart:developer';
import 'package:autotelematic_new_app/model/get_device_group_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:http/http.dart' as http;

class GetDeviceGroupRepository {
  Future<GetDeviceGroupModel?> getDeviceGroupApi({required int page}) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    final headers = {"Content-Type": "application/json"};
    final url = Uri.parse(
        "${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDeviceGroupEndPoint}$userApiHashKey");
    http.Response response = await http.get(headers: headers, url);
    log("Before 200 Response Data is that :${response.body}");
    log("Before 200 Response Data is that :${response.statusCode}");
    if (response.statusCode == 200) {
      log("After 200 Response Data is that :${response.body}");
      log("After 200 Response Data is that :${response.statusCode}");
      return getDeviceGroupModelFromJson(response.body);
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      log("Error Calling Api :${decodedBody['message']}");
      return null;
    }
  }
}
