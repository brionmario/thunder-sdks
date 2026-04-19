class SignOutOptions {
  final String? idTokenHint;
  final Map<String, dynamic> extra;

  const SignOutOptions({this.idTokenHint, this.extra = const {}});

  Map<String, dynamic> toMap() => {
        if (idTokenHint != null) 'idTokenHint': idTokenHint,
        ...extra,
      };
}
