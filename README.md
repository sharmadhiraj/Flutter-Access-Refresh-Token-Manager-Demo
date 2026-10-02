# Flutter Access Refresh Token Manager Demo

Handle access token expiration with a single refresh request, even when many API calls run
concurrently. Calls that find an expired token wait for the refresh already in progress instead of
starting their own.

## Prefer a package?

This pattern is published as a plugin:
[flutter_secure_token_manager](https://pub.dev/packages/flutter_secure_token_manager). It stores
tokens securely and manages refresh for you. Use this demo if you want the code in your own project
and full control over it.

## Implementation Guide

1. Add the dependencies:

   ```yaml
   dependencies:
     flutter_secure_storage: ^11.2.0
     http: ^1.6.0
     jwt_decoder: ^2.0.1
   ```

2. Copy these into your project:
    - `lib/auth/token_manager.dart`: refresh logic and request de-duplication
    - `lib/auth/token_storage.dart`: persistence (`SecureTokenStorage` uses
      `flutter_secure_storage`)
    - `lib/auth/session_expired_exception.dart`
    - `lib/models/token.dart`: adjust the fields and `fromJson` if your token response differs

3. Create the manager with a `refresher`, a function that exchanges the refresh token for a new
   `Token`. Throw an `ApiException` with the HTTP status on failure (see `lib/api/auth_api.dart`).

   ```dart
   final tokenManager = TokenManager(
     refresher: authApi.getNewAccessToken,
     storage: const SecureTokenStorage(),
   );
   ```

4. On app start, call `await tokenManager.load()` to restore a saved session. After a successful
   login, call `await tokenManager.setToken(token)`. On logout, call `await tokenManager.clear()`.

5. Attach the token to every authenticated request. Any HTTP client works (http, dio, others):

   ```dart
   headers: {"Authorization": "Bearer ${await tokenManager.getAccessToken()}"}
   ```

   `getAccessToken` refreshes the token first if it is expired. If the refresh token is rejected
   (400/401), the session is cleared and `SessionExpiredException` is thrown: catch it and send the
   user to login.

6. If your tokens are not JWTs, change `isTokenExpired` in `TokenManager`.

See `lib/api/api_client.dart` for a complete request example and `test/token_manager_test.dart` for
the concurrent refresh behavior.

## Run the demo

```
flutter pub get
flutter run
```

Tap **Login**, then **Expire token and send requests**. The activity timeline shows a single refresh
with the other requests waiting on it.
