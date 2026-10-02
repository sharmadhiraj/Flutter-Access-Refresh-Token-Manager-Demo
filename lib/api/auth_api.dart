import 'package:flutter_access_refresh_token_manager_demo/api/response_decoder.dart';
import 'package:flutter_access_refresh_token_manager_demo/config/api_config.dart';
import 'package:flutter_access_refresh_token_manager_demo/models/token.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  final http.Client _client;

  const AuthApi(this._client);

  Future<Token> login() async {
    final http.Response response = await _client.post(
      Uri.parse(ApiConfig.loginUrl),
      body: {
        "email": ApiConfig.demoEmail,
        "password": ApiConfig.demoPassword,
      },
    );
    return Token.fromJson(decodeResponse(response));
  }

  Future<Token> getNewAccessToken(String refreshToken) async {
    final http.Response response = await _client.post(
      Uri.parse(ApiConfig.refreshUrl),
      body: {"refreshToken": refreshToken},
    );
    return Token.fromJson(decodeResponse(response));
  }
}
