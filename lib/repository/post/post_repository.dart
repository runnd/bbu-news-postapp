import 'dart:io';
import 'package:get_storage/get_storage.dart';

import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/data/remote/network_api_service.dart';
import 'package:product_app/modules/post/base_post_request.dart';
import 'package:product_app/modules/post/post_base_request.dart';
import 'package:product_app/modules/post/post_base_response.dart';
import 'package:product_app/modules/post/post_category.dart';
import 'package:product_app/modules/post/post_request.dart';


class PostRepository {
  var storage = GetStorage();
  final _api = NetworkApiService();

  Future<PostBaseResponse> getAllPostCategories(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.postAppCategories, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getAllPostCategories: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> createPostCategory(PostCategory req) async {
    try {
      var response = await _api.postApi(ApiUrl.postCreateCategoryPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in createPostCategory: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getCategoryById(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.postCategoryByIdPath + req.id.toString(), req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getCategoryById: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getAllPosts(PostBaseRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.getAllPostPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getAllPosts: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getPostById(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.getPostByIdPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getPostById: $e");
      rethrow;
    }
  }

  // Create Post with Image upload
  Future<PostBaseResponse> createPost(PostRequest req) async{
    var response = await _api.postApi(ApiUrl.createPostPath, req.toJson());
    return PostBaseResponse.fromJson(response);
  }

  Future<PostBaseResponse> uploadImage(File imageFile) async {
    var response = await _api.uploadImage(imageFile);
    return PostBaseResponse.fromJson(response);
  }

}
