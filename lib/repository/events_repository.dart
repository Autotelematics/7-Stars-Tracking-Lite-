import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/events_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class EventsRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<EventsModel> getEventsFromAPI(String userApiHashKey, String fromDate,
      String toDate, String pageNumber) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.eventsEndPoint}$userApiHashKey&date_from=$fromDate&date_to=$toDate&page=$pageNumber');

      return EventsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EventsModel> destroyEventsAlertsApi(String userApiHashKey) async {
    try {
      dynamic response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.destroyEventsEndPoint}$userApiHashKey');
      return response = EventsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
