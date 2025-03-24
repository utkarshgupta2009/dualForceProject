import 'dart:developer';
import 'package:dual_force/data/network/base_api_services.dart';
import 'package:dual_force/data/network/network_api_services.dart';
import 'package:dual_force/data/response/api_response.dart';
import 'package:dual_force/res/api_endpoints.dart';


class AuthRepository  {
  final BaseApiService _apiService = NetworkApiService();
  // Sign up new user
  Future<ApiResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final url = ApiEndpoints.signup;
      final data = {"email": email, "password": password};

      final response = await _apiService.postResponse(url, data);
      final ApiResponse apiResponse = ApiResponse(
          getStatus(response['status']), response['data'], response['message']);
      print(response.toString());

     
      return apiResponse;
    } catch (e) {
      log('SignUp Error: $e');
      rethrow;
    }
  }

  // Login user
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = ApiEndpoints.login;
      final data = {"email": email, "password": password};

     final response = await _apiService.postResponse(url, data);
      final ApiResponse apiResponse = ApiResponse(
          getStatus(response['status']), response['data'], response['message']);
      print(response.toString());

     
      return apiResponse;
    } catch (e) {
      log('SignUp Error: $e');
      rethrow;
    }
  }
}
