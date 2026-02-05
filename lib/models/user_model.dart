class UserModel {
  final String email;
  final bool isWithinRange;

  UserModel({required this.email, this.isWithinRange = false});

  UserModel copyWith({String? email, bool? isWithinRange}) {
    return UserModel(
      email: email ?? this.email,
      isWithinRange: isWithinRange ?? this.isWithinRange,
    );
  }
}
