/// Base class for all SnapIT SDK exceptions.
class SnapITException implements Exception {
  final String message;
  SnapITException(this.message);

  @override
  String toString() => 'SnapITException: $message';
}

/// Thrown when the X-API-Key is invalid, missing, or revoked (HTTP 401).
class InvalidAPIKeyException extends SnapITException {
  InvalidAPIKeyException(String message) : super(message);
}

/// Thrown when the user ID does not match the key owner (HTTP 403).
class UnauthorizedException extends SnapITException {
  UnauthorizedException(String message) : super(message);
}

/// Thrown when the specified userId does not exist in the database (HTTP 404).
class UserNotFoundException extends SnapITException {
  UserNotFoundException(String message) : super(message);
}

/// Thrown when the user's credits are lower than the try-on credit cost (HTTP 501).
class InsufficientCreditsException extends SnapITException {
  InsufficientCreditsException(String message) : super(message);
}

/// Thrown when there is an underlying network/socket issue.
class NetworkException extends SnapITException {
  NetworkException(String message) : super(message);
}
