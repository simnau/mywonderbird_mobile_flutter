class AuthenticationException implements Exception {
  String cause;
  String errorCode;
  AuthenticationException(this.cause, {this.errorCode});
}
