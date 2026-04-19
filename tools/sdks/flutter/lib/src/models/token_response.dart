class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int? expiresIn;
  final String? refreshToken;
  final String? idToken;
  final String? scope;

  const TokenResponse({
    required this.accessToken,
    required this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.idToken,
    this.scope,
  });

  factory TokenResponse.fromMap(Map<dynamic, dynamic> map) => TokenResponse(
        accessToken: map['accessToken'] as String,
        tokenType: map['tokenType'] as String,
        expiresIn: map['expiresIn'] as int?,
        refreshToken: map['refreshToken'] as String?,
        idToken: map['idToken'] as String?,
        scope: map['scope'] as String?,
      );
}
