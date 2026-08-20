abstract class BaseAPIservices {
  Future<dynamic> getAPIresponse(String url);

  Future<dynamic> postAPIresponse(String url, dynamic data);
}
