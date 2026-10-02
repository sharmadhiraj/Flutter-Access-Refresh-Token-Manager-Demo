class Token {
  final String accessToken;
  final String refreshToken;

  const Token({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json["access_token"] as String,
      refreshToken: json["refresh_token"] as String,
    );
  }
}
