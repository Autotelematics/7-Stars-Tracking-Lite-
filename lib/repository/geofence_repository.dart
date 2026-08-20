import 'dart:convert';
import 'dart:developer';
import 'package:autotelematic_new_app/model/geofence_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:http/http.dart' as http;

class GeofenceRepository {
  GeofenceRepository();

  Future<GeofenceResponse> fetchGeofences() async {
    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      final url = Uri.parse(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getGeofencingApiEndPoint}$userApiHashKey');
      final headers = {"Content-Type": "application/json"};
      final response = await http.get(headers: headers, url);
      log("Before 200 Response Data is that :${response.body}");
      log("Before 200 Response Data is that :${response.statusCode}");
      if (response.statusCode == 200) {
        log("After 200 Response Data is that :${response.body}");
        log("After 200 Response Data is that :${response.statusCode}");

        final decoded = json.decode(response.body);
        log("Response Data is that :$decoded");
        return GeofenceResponse.fromJson(decoded);
      } else {
        throw Exception("Failed to load geofences: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
