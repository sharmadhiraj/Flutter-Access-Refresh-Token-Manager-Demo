import 'package:flutter_access_refresh_token_manager_demo/api/api_client.dart';
import 'package:flutter_access_refresh_token_manager_demo/api/auth_api.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_manager.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_storage.dart';
import 'package:flutter_access_refresh_token_manager_demo/logging/activity_log.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  final AuthApi authApi;
  final ApiClient apiClient;
  final TokenManager tokenManager;
  final ActivityLog activityLog;

  const AppDependencies._({
    required this.authApi,
    required this.apiClient,
    required this.tokenManager,
    required this.activityLog,
  });

  factory AppDependencies.create({
    http.Client? client,
    TokenStorage storage = const SecureTokenStorage(),
  }) {
    final http.Client httpClient = client ?? http.Client();
    final ActivityLog activityLog = ActivityLog();
    final AuthApi authApi = AuthApi(httpClient);
    final TokenManager tokenManager = TokenManager(
      refresher: authApi.getNewAccessToken,
      storage: storage,
      activityLog: activityLog,
    );
    return AppDependencies._(
      authApi: authApi,
      apiClient: ApiClient(
        httpClient,
        tokenManager,
        activityLog: activityLog,
      ),
      tokenManager: tokenManager,
      activityLog: activityLog,
    );
  }
}
