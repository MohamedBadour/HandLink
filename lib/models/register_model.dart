class RegisterRequestModel {
  final String displayName;
  final String phoneNumber;
  final String email;
  final String password;
  final String rePassword;

  RegisterRequestModel({
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.rePassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'rePassword': rePassword,
    };
  }
}

class RegisterResponseModel {
  final String displayName;
  final String email;
  final String token;
  final String message;
  final bool success;

  RegisterResponseModel({
    required this.displayName,
    required this.email,
    required this.token,
    required this.message,
    required this.success,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      message: json['message'] ?? '',
      success: true, // If we get a response, consider it successful
    );
  }

  // Constructor for error responses
  RegisterResponseModel.error({
    required this.message,
    this.success = false,
    this.displayName = '',
    this.email = '',
    this.token = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'token': token,
      'message': message,
      'success': success,
    };
  }
}
