import 'dart:convert';
import 'dart:developer';

import 'package:autotelematic_new_app/model/get_alerts_list_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetAlertListRepository {
  Future<GetAlertsModel?> getAlertListApi({
    required int page,
    String? deviceId,
    String? alertType,
    required BuildContext dialogContext,
  }) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();

    // Build the URL with possible filters
    String urlStr =
        "${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getAlertListEndPoint}$userApiHashKey&page=$page";
    if (deviceId != null && deviceId.isNotEmpty) {
      urlStr += "&device_id=$deviceId";
    }
    if (alertType != null && alertType.isNotEmpty) {
      urlStr += "&type=$alertType";
    }
    final headers = {"Content-Type": "application/json"};
    final url = Uri.parse(urlStr);

    try {
      http.Response response = await http.get(url, headers: headers);
      log('API Request URL: $url');
      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final GetAlertsModel alertsModel =
        getAlertsModelFromJson(response.body);
        log('Parsed Alert IDs (Page $page): ${alertsModel.items.map((item) => item.id).toList()}');
        return alertsModel;
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
        return null;
      }
    } catch (e) {
      log('Exception in getAlertListApi: $e');
      return null;
    }
  }
}
