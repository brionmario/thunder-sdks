class SignInOptions {
  final String? prompt;
  final String? loginHint;
  final String? fidp;
  final Map<String, dynamic> extra;

  const SignInOptions({this.prompt, this.loginHint, this.fidp, this.extra = const {}});

  Map<String, dynamic> toMap() => {
        if (prompt != null) 'prompt': prompt,
        if (loginHint != null) 'loginHint': loginHint,
        if (fidp != null) 'fidp': fidp,
        ...extra,
      };
}
