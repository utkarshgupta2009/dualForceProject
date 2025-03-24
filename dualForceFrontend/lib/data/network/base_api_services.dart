import 'dart:io';

abstract class BaseApiService {
  Future<dynamic> getResponse(String url, );
  Future<dynamic> getNonJsonResponse(String url, );
  Future<dynamic> postResponse(String url, dynamic data);

  Future<dynamic> postMultiPartResponse(String url,
      Map<String, dynamic>? data, File file);


  Future<dynamic> putMultiPartResponse(String url, 
      Map<String, dynamic>? data, Map<String, File>? files);
  Future<dynamic> patchMultiPartResponse(String url, 
      Map<String, dynamic>? data, Map<String, File>? files);
  Future<dynamic> patchResponse(String url,  dynamic data);
  Future<dynamic> putResponse(String url,  dynamic data);
  Future<dynamic> deleteResponse(String url,  dynamic data);
}
