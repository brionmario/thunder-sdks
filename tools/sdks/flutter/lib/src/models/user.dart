class User {
  final String sub;
  final String? username;
  final String? email;
  final String? displayName;
  final String? profilePicture;
  final bool? isNewUser;
  final Map<String, dynamic>? claims;

  const User({
    required this.sub,
    this.username,
    this.email,
    this.displayName,
    this.profilePicture,
    this.isNewUser,
    this.claims,
  });

  factory User.fromMap(Map<dynamic, dynamic> map) => User(
        sub: map['sub'] as String,
        username: map['username'] as String?,
        email: map['email'] as String?,
        displayName: map['displayName'] as String?,
        profilePicture: map['profilePicture'] as String?,
        isNewUser: map['isNewUser'] as bool?,
        claims: (map['claims'] as Map?)?.cast<String, dynamic>(),
      );
}
