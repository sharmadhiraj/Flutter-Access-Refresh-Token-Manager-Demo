import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_access_refresh_token_manager_demo/api.dart';
import 'package:flutter_access_refresh_token_manager_demo/token.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static TokenManager? _instance;

  static TokenManager get instance {
    _instance ??= TokenManager._();
    return _instance!;
  }

  String accessToken = "";
  String refreshToken = "";
  bool isRefreshing = false;
  Completer<void>? completer;

  TokenManager._();

  Future<String> getAccessToken() async {
    if (isTokenExpired() && !isRefreshing) {
      debugPrint("Token has expired, refreshing access token.");
      isRefreshing = true;
      completer = Completer<void>();
      await renewAccessToken();
      isRefreshing = false;
      completer?.complete();
    }
    if (isRefreshing) {
      debugPrint(
          "Already refreshing access token, waiting for it to complete.");
      await completer?.future;
    }
    return accessToken;
  }

  bool isTokenExpired() {
    return JwtDecoder.isExpired(accessToken);
  }

  Future<void> renewAccessToken() async {
    final Token token = await Api.getNewAccessToke(refreshToken);
    setToken(token);
  }

  void setToken(Token token) {
    accessToken = token.accessToken;
    refreshToken = token.refreshToken;
  }

  //Method added to just simulate access token expire and refresh process
  void expireAccessToken() {
    accessToken =
        "yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImlhdCI6MTY3Mjc2NjAyOCwiZXhwIjoxNjc0NDk0MDI4fQ.kCak9sLJr74frSRVQp0_27BY4iBCgQSmoT3vQVWKzJg";
  }
}
