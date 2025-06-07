class UserModel {
  final String name;
  final String phoneNumber;
  final String email;

  UserModel({
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}