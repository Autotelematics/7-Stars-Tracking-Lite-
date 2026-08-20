import 'dart:convert';
import 'dart:developer';
import 'package:autotelematic_new_app/model/get_device_list_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class GetDevicesListRepository {
  Future<GetDevicesListModel?> getDevicesListApi({required BuildContext dialogContext}) async {
    try {
      String? userApiHashKey = await UserSessions.getUserApiHash();
      final headers = {"Content-Type": "application/json"};
      final url = Uri.parse(
          "${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDeviceListEndPoint}$userApiHashKey");
      http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic>) {
          return getDevicesListModelFromJson(response.body);
        } else if (jsonData is List<dynamic>) {
          // For now, return null or throw an exception
          throw Exception('Expected Map<String, dynamic> but received List<dynamic>');
        } else {
          log("Unexpected Response Type: ${jsonData.runtimeType}");
          throw Exception('Unexpected response type: ${jsonData.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        log("Unauthorized: Redirecting to login");
        UserSessions.removeSession();
        Navigator.pushNamedAndRemoveUntil(
          dialogContext,
          RoutesName.login,
              (route) => false,
        );
        return null;
      } else {
        final dynamic decodedBody = jsonDecode(response.body);
        String errorMessage = 'Unknown error';
        if (decodedBody is Map && decodedBody.containsKey('message')) {
          errorMessage = decodedBody['message'].toString();
        }
        log("Error Calling API: $errorMessage");
        throw Exception('Error fetching devices: $errorMessage');
      }
    } catch (e) {
      log("Repository Error: $e");
      throw Exception('Error fetching devices: $e');
    }
  }
}