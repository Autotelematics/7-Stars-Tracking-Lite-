import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/getreportmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class GetReportsRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<GetReportModel> getReportsFromAPI(
      String userApiHashKey, String getReportDateTime) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.generateReports}$userApiHashKey$getReportDateTime');

      return GetReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
