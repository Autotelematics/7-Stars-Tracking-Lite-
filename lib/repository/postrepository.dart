import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/postmodel.dart';
import 'package:dio/dio.dart';

class PostRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<List<PostModel>> fetchPosts() async {
    try {
      Response response = await networkAPI.sendRequest
          .get("https://jsonplaceholder.typicode.com/posts");
      List<dynamic> postMaps = response.data;

      return postMaps.map((postMap) => PostModel.fromJson(postMap)).toList();
    } catch (exp) {
      rethrow;
      //
    }
  }
}
