class AuthenticationException implements Exception {
  String cause;
  String errorCode;
  AuthenticationException(cause, {this.errorCode});
}
