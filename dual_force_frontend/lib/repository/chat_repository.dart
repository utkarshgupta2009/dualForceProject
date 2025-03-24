import 'package:dual_force/data/network/base_api_services.dart';
import 'package:dual_force/data/network/network_api_services.dart';
import 'package:dual_force/data/response/api_response.dart';

import 'package:dual_force/models/message.dart';
import 'package:dual_force/res/api_endpoints.dart';

class ChatRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<ApiResponse> sendMessage({
    required String expertSystemId,
    required String query,
    required List<Message> conversationMessages,
    int limit = 5,
  }) async {
    ApiResponse apiResponse;
    try {
      // Construct the URL with query parameters
      final url =
          '${ApiEndpoints.sendMessage}?expertSystemId=$expertSystemId&query=$query&limit=$limit';

      // Convert conversation messages to a list of maps for serialization
      final List<Map<String, dynamic>> messagesBody =
          conversationMessages.map((message) => message.toMap()).toList();

      // Send the request with conversation messages as the body
      final rawResponse = await _apiService.postResponse(url, messagesBody);

      // Parse the response to extract the actual message
      apiResponse = ApiResponse(getStatus(rawResponse['status']),
          rawResponse['data'], rawResponse['message']);

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }
}
