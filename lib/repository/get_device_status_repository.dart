import 'dart:convert';
import 'dart:developer';
import 'package:autotelematic_new_app/model/get_device_status_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class GetDeviceStatusRepository {
  Future<GetDeviceStatusModel?> getDeviceStatusApi(
      {required BuildContext dialogContext}) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    final headers = {"Content-Type": "application/json"};
    final url = Uri.parse(
        "${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDeviceStatusEndPoint}$userApiHashKey");
    http.Response response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      return getDeviceStatusModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      log("Unauthorized: Redirecting to login");
      UserSessions.removeSession();
      // Clear the navigation stack and navigate to login
      Navigator.pushNamedAndRemoveUntil(
        dialogContext,
        RoutesName.login,
        (route) => false,
      );
      return null;
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      log("Error Calling Api :${decodedBody['message']}");
      return null;
    }
  }
}
