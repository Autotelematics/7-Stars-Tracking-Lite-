import 'dart:convert';
import 'dart:developer';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:http/http.dart' as http;

class DeleteAlertRepository {
  Future<bool> deleteAlert({required List<int> alertIds}) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    final headers = {"Content-Type": "application/json"};
    final url = Uri.parse(
        "${ApiEndpointUrls.baseURL}${ApiEndpointUrls.deleteAlertEndPoint}$userApiHashKey");
    final body = jsonEncode({"ids": alertIds}); // Send list of IDs in the body
    http.Response response = await http.delete(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      log("Error Calling Api: ${decodedBody['message']}");
      return false;
    }
  }
}