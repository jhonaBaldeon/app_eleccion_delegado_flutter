class UserModel {
  final String email;
  final String? name; //el signo ? quiere decir que la peticion del atributo es opcional.
  final String? photoUrl;
  final bool isWithinRange;

  UserModel({
    required this.email,
    this.name,
    this.photoUrl,
    this.isWithinRange = false,
  });

  UserModel copyWith({
    String? email,
    String? name,
    String? photoUrl,
    bool? isWithinRange,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isWithinRange: isWithinRange ?? this.isWithinRange,
    );
  }
}
