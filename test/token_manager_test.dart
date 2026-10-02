import 'dart:convert';

import 'package:flutter_access_refresh_token_manager_demo/api/api_exception.dart';
import 'package:flutter_access_refresh_token_manager_demo/models/token.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/session_expired_exception.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_manager.dart';
import 'package:flutter_access_refresh_token_manager_demo/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage implements TokenStorage {
  Token? token;

  @override
  Future<Token?> read() async => token;

  @override
  Future<void> write(Token token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}

String _jwt(int expSeconds) {
  String enc(String s) => base64Url.encode(utf8.encode(s)).replaceAll("=", "");
  return "${enc('{"alg":"HS256","typ":"JWT"}')}.${enc('{"exp":$expSeconds}')}.sig";
}

void main() {
  final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final String validJwt = _jwt(now + 3600);
  final String expiredJwt = _jwt(now - 3600);

  late _MemoryStorage storage;

  setUp(() => storage = _MemoryStorage());

  test("parallel calls with an expired token trigger a single refresh",
      () async {
    int refreshCount = 0;
    final TokenManager manager = TokenManager(
      refresher: (_) async {
        refreshCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return Token(accessToken: validJwt, refreshToken: "r2");
      },
      storage: storage,
    );
    await manager.setToken(Token(accessToken: expiredJwt, refreshToken: "r1"));

    final List<String> tokens = await Future.wait(
      List.generate(5, (_) => manager.getAccessToken()),
    );

    expect(refreshCount, 1);
    expect(tokens, everyElement(validJwt));
    expect((await storage.read())?.refreshToken, "r2");
  });

  test("valid token is returned without refreshing", () async {
    int refreshCount = 0;
    final TokenManager manager = TokenManager(
      refresher: (_) async {
        refreshCount++;
        return Token(accessToken: validJwt, refreshToken: "r2");
      },
      storage: storage,
    );
    await manager.setToken(Token(accessToken: validJwt, refreshToken: "r1"));

    expect(await manager.getAccessToken(), validJwt);
    expect(refreshCount, 0);
  });

  test("rejected refresh token clears the session", () async {
    final TokenManager manager = TokenManager(
      refresher: (_) async => throw const ApiException(401, "unauthorized"),
      storage: storage,
    );
    await manager.setToken(Token(accessToken: expiredJwt, refreshToken: "r1"));

    await expectLater(
      manager.getAccessToken(),
      throwsA(isA<SessionExpiredException>()),
    );
    expect(manager.hasSession, isFalse);
    expect(await storage.read(), isNull);
  });

  test("failed refresh does not block later attempts", () async {
    int calls = 0;
    final TokenManager manager = TokenManager(
      refresher: (_) async {
        calls++;
        if (calls == 1) {
          throw const ApiException(500, "boom");
        }
        return Token(accessToken: validJwt, refreshToken: "r2");
      },
      storage: storage,
    );
    await manager.setToken(Token(accessToken: expiredJwt, refreshToken: "r1"));

    await expectLater(
      manager.getAccessToken(),
      throwsA(isA<ApiException>()),
    );
    expect(await manager.getAccessToken(), validJwt);
  });

  test("empty token is treated as expired", () {
    final TokenManager manager = TokenManager(
      refresher: (_) async => throw Exception(),
      storage: storage,
    );
    expect(manager.isTokenExpired(), isTrue);
  });
}
