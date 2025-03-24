import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Use different base URLs depending on the platform
  static final String baseUrl = dotenv.get("BASE_URL");
  
  // API endpoints
  static final login = "$baseUrl/auth/login";
  static final signup = "$baseUrl/auth/signup";
  static final createExpertSystem = "$baseUrl/expertSystem/create";
  static final sendMessage = "$baseUrl/expertSystem/sendMessage";
  

}