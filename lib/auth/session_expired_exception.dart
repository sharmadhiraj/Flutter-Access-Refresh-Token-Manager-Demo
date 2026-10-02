class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => "Session expired, please log in again.";
}
