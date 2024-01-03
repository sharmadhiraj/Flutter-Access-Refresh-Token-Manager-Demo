class Token {
  final String accessToken;
  final String refreshToken;

  Token({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
    );
  }

  static List<Token> parseList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List || jsonList.isEmpty) {
      return [];
    }
    return jsonList.map((json) => Token.fromJson(json)).toList();
  }
}
