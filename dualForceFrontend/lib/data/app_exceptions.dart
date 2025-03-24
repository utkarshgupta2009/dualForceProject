class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised Request: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

// Added for 404 responses
class NotFoundException extends AppException {
  NotFoundException([String? message]) : super(message, "Not Found: ");
}

// Added for 500 responses
class ServerException extends AppException {
  ServerException([String? message]) : super(message, "Server Error: ");
}

// For handling timeout scenarios
class TimeoutException extends AppException {
  TimeoutException([String? message]) : super(message, "Connection Timeout: ");
}

// For handling connection issues
class ConnectionException extends AppException {
  ConnectionException([String? message]) : super(message, "Connection Error: ");
}

// For handling response parsing errors
class ParseException extends AppException {
  ParseException([String? message]) : super(message, "Parsing Error: ");
}