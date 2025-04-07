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
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  RegisterResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}