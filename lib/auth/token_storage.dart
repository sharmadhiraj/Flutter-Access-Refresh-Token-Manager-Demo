import 'package:flutter_access_refresh_token_manager_demo/models/token.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<Token?> read();

  Future<void> write(Token token);

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const String _accessKey = "access_token";
  static const String _refreshKey = "refresh_token";

  final FlutterSecureStorage _storage;

  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<Token?> read() async {
    final String? access = await _storage.read(key: _accessKey);
    final String? refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) {
      return null;
    }
    return Token(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> write(Token token) async {
    await _storage.write(key: _accessKey, value: token.accessToken);
    await _storage.write(key: _refreshKey, value: token.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
