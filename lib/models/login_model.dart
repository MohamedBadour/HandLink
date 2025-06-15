class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponseModel {
  final String displayName;
  final String email;
  final String token;
  final String message;

  LoginResponseModel({
    required this.displayName,
    required this.email,
    required this.token,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'token': token,
      'message': message,
    };
  }
}
