import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dual_force/data/app_exceptions.dart';
import 'package:dual_force/data/network/base_api_services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class NetworkApiService extends BaseApiService {
  @override
  Future getResponse(String url) async {
    dynamic responseJson;

    try {
      final response = await http.get(Uri.parse(url));

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @override
  Future getNonJsonResponse(
    String url,
  ) async {
    dynamic response;

    try {
      response = await http.get(Uri.parse(url));
      //responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return response;
  }

  @override
  Future postResponse(String url, dynamic data) async {
    dynamic responseJson;

    var headers = {
      'Content-Type': 'application/json',
    };
    String jsonBody = jsonEncode(data);

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: jsonBody);
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @override
  Future postMultiPartResponse(
      String url, Map<String, dynamic>? data, File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add form fields
      if (data != null) {
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }

      // Add file
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        "file",
        file.path,
        contentType:
            MediaType('application', 'pdf'), // Explicitly set content type
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var responseJson = returnResponse(responseData);

      return responseJson;
    } catch (error) {
      log('Error uploading post data: $error');
      rethrow;
    }
  }

  @override
  Future patchResponse(String url, dynamic data) async {
    dynamic responseJson;

    var headers = {
      'Content-Type': 'application/json',
    };
    String jsonBody = jsonEncode(data);
    try {
      final response =
          await http.patch(Uri.parse(url), headers: headers, body: jsonBody);

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @override
  Future patchMultiPartResponse(
      String url, Map<String, dynamic>? data, Map<String, File>? files) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(url));

      if (data != null) {
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value;
          }
        });
      }

      if (files != null) {
        files.forEach((name, file) async {
          var mimeType = lookupMimeType(file.path)?.split('/');
          http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
              name, file.path,
              contentType: mimeType != null
                  ? MediaType(mimeType[0], mimeType[1])
                  : null);
          request.files.add(multipartFile);
        });
      }
      print('Files uploaded in PATCH');

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var responseJson = jsonDecode(responseData.body);

      return responseJson;
    } catch (error) {
      print('Error uploading post data: $error');
    }
  }

  @override
  Future putResponse(String url, dynamic data) async {
    dynamic responseJson;

    String jsonBody = jsonEncode(data);
    try {
      final response = await http.put(Uri.parse(url), body: jsonBody);
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @override
  Future putMultiPartResponse(
      String url, Map<String, dynamic>? data, Map<String, File>? files) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add data fields
      if (data != null) {
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value;
          }
        });
      }

      // Add the file if provided
      if (files != null) {
        files.forEach((name, file) async {
          var mimeType = lookupMimeType(file.path)?.split('/');
          http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
              name, file.path,
              contentType: mimeType != null
                  ? MediaType(mimeType[0], mimeType[1])
                  : null);
          request.files.add(multipartFile);
        });
      }
      print('files uploaded in PUT');

      // Send the request and await the response
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var responseJson = jsonDecode(responseData.body);
      print(responseJson.toString());
      return responseJson;
    } catch (error) {
      print('Error uploading put data: $error');
    }
  }

  @override
  Future deleteResponse(String url, dynamic data) async {
    dynamic responseJson;

    var headers = {
      'Content-Type': 'application/json',
    };
    String jsonBody = jsonEncode(data);
    try {
      final response =
          await http.delete(Uri.parse(url), headers: headers, body: jsonBody);
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {}
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // If JSON parsing fails, return the raw body
        return response.body;
      }
    }
    // switch (response.statusCode) {
    //   case 200: // For successful GET requests
    //   case 201: // For successful POST or PUT requests
    //   case 202: // For accepted but not yet processed
    //     // Only decode if there's content
    //     if (response.body.isNotEmpty) {
    //       try {
    //         return jsonDecode(response.body);
    //       } catch (e) {
    //         // If JSON parsing fails, return the raw body
    //         return response.body;
    //       }
    //     }
    //     return null;

    //   case 204: // For successful DELETE requests (No Content)
    //     return null; // No content to return

    //   case 308: // Permanent Redirect
    //     return {'redirectUrl': response.headers['location']};

    //   case 400:
    //     throw BadRequestException('Bad request: ${response.body}');

    //   case 401:
    //     throw UnauthorisedException('Unauthorized: ${response.body}');

    //   case 403:
    //     throw UnauthorisedException('Forbidden: ${response.body}');

    //   case 404:
    //     throw NotFoundException('Resource not found: ${response.body}');

    //   case 500:
    //     throw ServerException('Server error: ${response.body}');

    //   default:
    //     throw FetchDataException(
    //         'Error occurred while communicating with the server with status code: ${response.statusCode}\nResponse: ${response.body}');
    // }
  }
}
