import 'dart:async';

import 'package:flutter_access_refresh_token_manager_demo/api/api_exception.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';
import 'package:flutter_access_refresh_token_manager_demo/models/token.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/session_expired_exception.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static const String _expiredAccessToken =
      "yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImlhdCI6MTY3Mjc2NjAyOCwiZXhwIjoxNjc0NDk0MDI4fQ.kCak9sLJr74frSRVQp0_27BY4iBCgQSmoT3vQVWKzJg";

  final Future<Token> Function(String refreshToken) _refresher;
  final TokenStorage _storage;
  final ActivityLog _log;

  String _accessToken = "";
  String _refreshToken = "";
  Future<void>? _refreshFuture;

  TokenManager({
    required Future<Token> Function(String refreshToken) refresher,
    required TokenStorage storage,
    ActivityLog? activityLog,
  })  : _refresher = refresher,
        _storage = storage,
        _log = activityLog ?? ActivityLog();

  bool get hasSession => _refreshToken.isNotEmpty;

  Future<void> load() async {
    final Token? token = await _storage.read();
    if (token != null) {
      _accessToken = token.accessToken;
      _refreshToken = token.refreshToken;
    }
  }

  DateTime? get accessTokenExpiry => _timestamp("exp");

  DateTime? get accessTokenIssuedAt => _timestamp("iat");

  Future<String> getAccessToken({String requester = "Request"}) async {
    if (!hasSession) {
      throw const SessionExpiredException();
    }
    if (isTokenExpired()) {
      _log.add(
        _refreshFuture == null ? ActivityKind.refresh : ActivityKind.waiting,
        _refreshFuture == null
            ? "$requester found an expired token, refresh started"
            : "$requester waits for the refresh in progress",
      );
      await (_refreshFuture ??= _renewAccessToken().whenComplete(
        () => _refreshFuture = null,
      ));
    }
    return _accessToken;
  }

  bool isTokenExpired() {
    if (_accessToken.isEmpty) {
      return true;
    }
    try {
      return JwtDecoder.isExpired(_accessToken);
    } on FormatException {
      return true;
    }
  }

  Future<void> setToken(Token token) async {
    _accessToken = token.accessToken;
    _refreshToken = token.refreshToken;
    await _storage.write(token);
  }

  Future<void> clear() async {
    _accessToken = "";
    _refreshToken = "";
    await _storage.clear();
  }

  //Method added to just simulate access token expire and refresh process
  void expireAccessToken() {
    _accessToken = _expiredAccessToken;
  }

  DateTime? _timestamp(String claim) {
    try {
      final Object? seconds = JwtDecoder.decode(_accessToken)[claim];
      return seconds is int
          ? DateTime.fromMillisecondsSinceEpoch(seconds * 1000)
          : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> _renewAccessToken() async {
    try {
      await setToken(await _refresher(_refreshToken));
      _log.add(ActivityKind.success, "Refresh complete, new tokens saved");
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401) {
        await clear();
        _log.add(ActivityKind.error, "Refresh token rejected, session ended");
        throw const SessionExpiredException();
      }
      _log.add(ActivityKind.error, "Refresh failed (${e.statusCode})");
      rethrow;
    }
  }
}
