class SignUpOptions {
  final String? appId;
  final Map<String, dynamic> extra;

  const SignUpOptions({this.appId, this.extra = const {}});

  Map<String, dynamic> toMap() => {
        if (appId != null) 'appId': appId,
        ...extra,
      };
}
