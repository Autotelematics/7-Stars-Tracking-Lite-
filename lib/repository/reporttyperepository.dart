import 'dart:developer';
import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/reporttypemodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class ReportTypeRepository {
  final NetworkAPI networkAPI = NetworkAPI();

  Future<ReportTypeModel> getReportsTypeFromAPI(String userApiHashKey) async {
    try {
      // Validate userApiHashKey
      if (userApiHashKey.isEmpty) {
        throw Exception('User API hash key is empty');
      }

      // Construct and log the API URL
      final url =
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.generateReportType}$userApiHashKey';
      // print('API Request URL: $url');

      // Make the API request with timeout
      final response = await networkAPI.sendRequest.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      // Log the response data
      print('API Response Data: ${response.data}');
      log('API Response Data: ${response.data}');

      // Validate response data
      if (response.data == null) {
        throw Exception('Empty response from API');
      }

      // Parse and return the response
      return ReportTypeModel.fromJson(response.data);
    } catch (e) {
      // Log the error for debugging
      // print('API Error in getReportsTypeFromAPI: $e');
      rethrow; // Rethrow to let the cubit handle the error
    }
  }
}
