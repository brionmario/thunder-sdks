class TokenExchangeRequestConfig {
  final String subjectToken;
  final String subjectTokenType;
  final String? requestedTokenType;
  final String? audience;

  const TokenExchangeRequestConfig({
    required this.subjectToken,
    required this.subjectTokenType,
    this.requestedTokenType,
    this.audience,
  });

  Map<String, dynamic> toMap() => {
        'subjectToken': subjectToken,
        'subjectTokenType': subjectTokenType,
        if (requestedTokenType != null) 'requestedTokenType': requestedTokenType,
        if (audience != null) 'audience': audience,
      };
}
