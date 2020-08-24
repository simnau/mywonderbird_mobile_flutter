import 'package:http_interceptor/http_interceptor.dart';
import 'package:mywonderbird/constants/auth.dart';
import 'package:mywonderbird/services/token.dart';

class AuthenticationInterceptor implements InterceptorContract {
  final TokenService tokenService;

  AuthenticationInterceptor({this.tokenService});

  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    final accessToken = await tokenService.getAccessToken();

    if (accessToken != null) {
      data.headers[AUTHORIZATION_HEADER] = accessToken;
    }

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    return data;
  }
}
