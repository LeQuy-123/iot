class AccessToken {
  String accessToken;
  int expiresIn;
  int refreshExpiresIn;
  String tokenType;
  int notBeforePolicy;
  String scope;

  AccessToken({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
    required this.notBeforePolicy,
    required this.scope,
  });

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
      notBeforePolicy: json['not-before-policy'],
      scope: json['scope'],
    );
  }
}
