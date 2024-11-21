import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:product_app/data/app_exceptions.dart';
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/data/remote/base_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:product_app/modules/post/login/login_res.dart';
import 'package:product_app/modules/post/login/refresh_token_request.dart';
import 'package:product_app/routes/app_routes.dart';

class NetworkApiService implements BaseApiServer {
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) print("GET REQUEST URL: $url\n");
    dynamic responseJson;

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 120));
      if (kDebugMode) print("RESPONSE STATUS: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          try {
            responseJson = jsonDecode(response.body);
            if (responseJson is! Map<String, dynamic>) {
              throw FormatException("Expected a Map, but received something else.");
            }
          } catch (e) {
            throw FormatException("Error parsing response body: $e");
          }
          break;
        case 400:
          throw UnAuthorization();
        case 500:
          throw InternalServerException();
        default:
          throw Exception('Unexpected error occurred: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }

    if (kDebugMode) print("GET RESPONSE BODY: $responseJson\n");
    return responseJson;
  }

  @override
  Future<dynamic> postApi(String url, dynamic requestBody, {Map<String, String>? headers}) async {
    print("POST REQUEST URL: $url\nBODY: $requestBody\n");
    dynamic responseJson;

    try {
      var storage = GetStorage();
      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = user.accessToken ?? "";

      headers ??= {};
      headers['Content-Type'] = 'application/json';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 120));

      switch (response.statusCode) {
        case 200:
          try {
            responseJson = jsonDecode(response.body);
          } catch (e) {
            throw FormatException("Error parsing response body: $e");
          }
          break;
        case 401:
          if (await refreshTokenApi()) {
            print("Token refreshed - retrying request.");
            return _retry(url, requestBody, headers);
          } else {
            print("Token refresh failed. Logging out.");
            throw UnAuthorization();
          }
        case 500:
          throw InternalServerException();
        default:
          throw Exception(
              'Error with status code: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }

    return responseJson;
  }

  Future<dynamic> uploadImageApi(String url, File imageFile) async {
    if (kDebugMode) {
      print("UPLOAD IMAGE REQUEST URL $url");
    }

    dynamic responseJson;
    try {
      var storage = GetStorage();

      if (storage.read("USER_KEY") == null) {
        Get.offAllNamed(RouteName.postSplash);
      }

      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = user.accessToken ?? "";

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print("STATUS CODE UPLOAD: ${response.statusCode}");
        print("RESPONSE UPLOAD: $responseBody");
      }

      switch (response.statusCode) {
        case 200:
          responseJson = jsonDecode(responseBody);
          print("UPLOAD IMAGE SUCCESS");
          break;
        case 401:
          print("UPLOAD IMAGE CODE 401 - Unauthorized");
          if (await refreshTokenApi() == true) {
            responseJson = await uploadImageApi(url, imageFile); // Retry after refreshing token
          } else {
            Get.offAllNamed(RouteName.postSplash);
          }
          break;
        case 403:
          print("UPLOAD IMAGE CODE 403 - Forbidden");
          if (await refreshTokenApi() == true) {
            responseJson = await uploadImageApi(url, imageFile); // Retry after refreshing token
          } else {
            Get.offAllNamed(RouteName.postSplash);
          }
          break;
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Failed to upload image");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    }

    if (kDebugMode) {
      print("UPLOAD IMAGE RESPONSE BODY: $responseJson\n");
    }
    return responseJson;
  }

  Future<Map<String, dynamic>> uploadImage(File image) async {
    var storage = GetStorage();
    final url = Uri.parse(ApiUrl.postUploadImagePath);
    // Map<String, dynamic> responseJson;
    dynamic responseJson;
    try {
      // Create a multipart request
      var request = http.MultipartRequest("POST", url);

      // Attach the image file as a multipart file
      final mimeTypeData = lookupMimeType(image.path)!.split('/'); // Get mime type
      request.files.add(
        http.MultipartFile(
          'File',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: image.path.split('/').last,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Retrieve and set the authorization token
      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = user.accessToken ?? "";
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Accept'] = '*/*';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      switch(response.statusCode){
        case 200:
          responseJson = jsonDecode(responseBody);
          print("Image uploaded successfully2: ${responseJson["data"]['data']}");
        case 401:
          if (await refreshTokenApi() == true) {
            print("ON RETRY REFRESH");
            responseJson = await refreshUploadImage(image);

          } else {
            storage.remove("USER_KEY");
            Get.offAllNamed(RouteName.postSplash);
          }
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Failed to upload image");
      }
    } catch (e) {
      print("Image upload failed: $e");
      throw Exception("Image upload failed: $e");
    }

    return responseJson;
  }

  Future<Map<String, dynamic>> refreshUploadImage(File image) async {
    var storage = GetStorage();
    final url = Uri.parse(ApiUrl.postUploadImagePath);
    // Map<String, dynamic> responseJson;
    dynamic responseJson;

    try {
      // Create a multipart request
      var request = http.MultipartRequest("POST", url);

      // Attach the image file as a multipart file
      final mimeTypeData = lookupMimeType(image.path)!.split('/'); // Get mime type
      request.files.add(
        http.MultipartFile(
          'File',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: image.path.split('/').last,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Retrieve and set the authorization token
      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = user.accessToken ?? "";
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Accept'] = '*/*';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      switch(response.statusCode){
        case 200:
          responseJson = jsonDecode(responseBody);
          print("Image uploaded successfully2: ${responseJson["data"]['data']}");
        case 401:
          storage.remove("USER_KEY");
          Get.offAllNamed(RouteName.postSplash);
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Failed to upload image");
      }
    } catch (e) {
      print("Image upload failed: $e");
      throw Exception("Image upload failed: $e");
    }

    return responseJson;
  }

  Future refreshTokenUploadImage(File image) async {
    final url = Uri.parse(ApiUrl.postUploadImagePath);
    print("REFRESH TOKEN");
    dynamic responseJson;
    try {
      var storage = GetStorage();
      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = "";
      if (user.refreshToken != null) {
        token = user.accessToken ?? "";
      }
      try {
        // Create a multipart request
        var request = http.MultipartRequest("POST", url);

        // Attach the image file as a multipart file
        final mimeTypeData = lookupMimeType(image.path)!.split('/'); // Get mime type
        request.files.add(
          http.MultipartFile(
            'File',
            image.readAsBytes().asStream(),
            image.lengthSync(),
            filename: image.path.split('/').last,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );

        // Retrieve and set the authorization token
        var user = LoginRes.fromJson(storage.read("USER_KEY"));
        var token = user.accessToken ?? "";
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Cache-Control'] = 'no-cache';
        request.headers['Accept'] = '*/*';

        // Send the request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();


        switch (response.statusCode) {
          case 200:
            responseJson = responseBody;
            print("REFRESH API CODE 200");
        // break;
          case 401:
            print("REFRESH API CODE 401");
            // if (await refreshTokenApi() == true) {
            //   print("ON RETRY REFRESH");
            // } else {
            storage.remove("USER_KEY");
            Get.offAllNamed(RouteName.postSplash);
        // }
          case 500:
            throw InternalServerException();
        }
      } catch (e) {
        print("Image upload failed: $e");
        throw Exception("Image upload failed: $e");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    }
    return responseJson;
  }

  @override
  Future<dynamic> registerApi(String url, dynamic requestBody) async {
    if (kDebugMode) print("REGISTER REQUEST URL: $url\nBODY: $requestBody\n");
    dynamic responseJson;

    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) print("REGISTER RESPONSE STATUS: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          try {
            responseJson = jsonDecode(response.body);
            if (responseJson is! Map<String, dynamic>) {
              throw FormatException("Unexpected response format in registration.");
            }
          } catch (e) {
            throw FormatException("Error parsing response body: $e");
          }
          break;
        case 400:
          throw UnAuthorization();
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Unexpected error occurred: ${response.statusCode}");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }

    if (kDebugMode) print("REGISTER RESPONSE BODY: $responseJson\n");
    return responseJson;
  }

  @override
  Future<dynamic> LoginApi(String url, dynamic requestBody) async {
    if (kDebugMode) print("LOGIN REQUEST URL: $url\nBODY: $requestBody\n");
    dynamic responseJson;

    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) print("LOGIN RESPONSE STATUS: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          try {
            responseJson = jsonDecode(response.body);
            if (responseJson is! Map<String, dynamic>) {
              throw FormatException("Unexpected response format in login.");
            }
          } catch (e) {
            throw FormatException("Error parsing response body: $e");
          }
          break;
        case 401:
          throw UnAuthorization();
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Unexpected error occurred: ${response.statusCode}");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }

    if (kDebugMode) print("LOGIN RESPONSE BODY: $responseJson\n");
    return responseJson;
  }

  Future<bool> refreshTokenApi() async {
    final storage = GetStorage();

    try {
      final headers = {'Content-Type': 'application/json'};
      final user = LoginRes.fromJson(storage.read("USER_KEY"));
      final refreshTokenRequest = RefreshTokenRequest(refreshToken: user.refreshToken);

      final response = await http
          .post(Uri.parse(ApiUrl.postAppRefreshTokenPath), headers: headers, body: jsonEncode(refreshTokenRequest))
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) print("REFRESH TOKEN RESPONSE STATUS: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          final responseJson = LoginRes.fromJson(jsonDecode(response.body));
          await storage.write("USER_KEY", responseJson.toJson());
          return true;
        case 401:
          await storage.remove("USER_KEY");
          Get.offAllNamed(RouteName.postSplash);
          return false;
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Unexpected error occurred: ${response.statusCode}");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> _retry(String url, dynamic requestBody, Map<String, String>? headers) async {
    dynamic responseJson;
    final storage = GetStorage();
    final user = LoginRes.fromJson(storage.read("USER_KEY"));
    final token = user.accessToken ?? "";

    if (kDebugMode) print("RETRYING WITH TOKEN: $token");

    try {
      if (headers == null) headers = {};
      headers['Authorization'] = 'Bearer $token';

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) print("RETRY RESPONSE STATUS: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          try {
            responseJson = jsonDecode(response.body);
          } catch (e) {
            throw FormatException("Error parsing response body: $e");
          }
          break;
        case 403:
          if (kDebugMode) {
            print("403 Forbidden - Response Body: ${response.body}");
          }
          throw ("Access is forbidden: ${response.body}");
        case 500:
          throw InternalServerException();
        default:
          throw Exception("Unexpected error occurred: ${response.statusCode}");
      }
    } on SocketException {
      throw NoInternetConnectionException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }

    return responseJson;
  }








}

