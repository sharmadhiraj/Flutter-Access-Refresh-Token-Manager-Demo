import 'package:flutter_access_refresh_token_manager_demo/api/response_decoder.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_manager.dart';
import 'package:flutter_access_refresh_token_manager_demo/config/api_config.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final TokenManager _tokenManager;
  final ActivityLog? _log;
  int _requestCount = 0;

  ApiClient(this._client, this._tokenManager, {ActivityLog? activityLog})
      : _log = activityLog;

  Future<Map<String, dynamic>> makeApiCall(String url) async {
    final String name = "Request #${++_requestCount}";
    final String path = Uri.parse(url).path;
    _log?.add(ActivityKind.request, "$name started: GET $path");
    try {
      final String accessToken = await _tokenManager.getAccessToken(
        requester: name,
      );
      final http.Response response = await _client.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $accessToken"},
      );
      final Map<String, dynamic> body = decodeResponse(response);
      _log?.add(
        ActivityKind.response,
        "$name completed (${response.statusCode})",
      );
      return body;
    } catch (e) {
      _log?.add(ActivityKind.error, "$name failed: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchProfile() {
    return makeApiCall(ApiConfig.profileUrl);
  }
}
