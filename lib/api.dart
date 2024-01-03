import 'dart:convert';

import 'package:flutter_access_refresh_token_manager_demo/token.dart';
import 'package:flutter_access_refresh_token_manager_demo/token_manager.dart';
import 'package:http/http.dart' as http;

class Api {
  static Future<Token> login() async {
    final dynamic response = await http.post(
      Uri.parse("https://api.escuelajs.co/api/v1/auth/login"),
      body: {
        "email": "john@mail.com",
        "password": "changeme",
      },
    );
    return Token.fromJson(jsonDecode(response.body));
  }

  static Future<Token> getNewAccessToke(String refreshToken) async {
    final dynamic response = await http.post(
      Uri.parse("https://api.escuelajs.co/api/v1/auth/refresh-token"),
      body: {
        "refreshToken": refreshToken,
      },
    );
    return Token.fromJson(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> makeApiCall(String url) async {
    final dynamic response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization":
            "Bearer ${await TokenManager.instance.getAccessToken()}"
      },
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchProfile() async {
    return await makeApiCall("https://api.escuelajs.co/api/v1/auth/profile");
  }
}
