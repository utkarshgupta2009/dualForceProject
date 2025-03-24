import 'dart:developer';
import 'dart:io';

import 'package:dual_force/data/network/base_api_services.dart';
import 'package:dual_force/data/network/network_api_services.dart';
import 'package:dual_force/data/response/api_response.dart';
import 'package:dual_force/res/api_endpoints.dart';

class ExpertSystemRepository {
  final BaseApiService _apiService = NetworkApiService();

Future<ApiResponse> createExpertSystem(
    File file, String userId, String name, String description) async {
  try {
    final url = ApiEndpoints.createExpertSystem;
    
    // Create map with all required form fields
    final data = {
      "userId": userId,
      "name": name,
      "description": description,
      "autoTruncate": "true" // Include default value
    };
    
    // Check file extension for PDF
    if (!file.path.toLowerCase().endsWith('.pdf')) {
      return ApiResponse(Status.ERROR, null, "Only PDF files are supported");
    }
    
    final response = await _apiService.postMultiPartResponse(url, data, file);
    
    final ApiResponse apiResponse = ApiResponse(
        getStatus(response['status']), response['data'], response['message']);
    return apiResponse;
  } catch (e) {
    log("Create expert system error: ${e.toString()}");
    rethrow;
  }
}
}
