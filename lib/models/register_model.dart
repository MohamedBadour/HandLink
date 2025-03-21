class RegisterRequestModel {
  final String displayName;
  final String email;
  final String password;
  final String rePassword;
  final String phoneNumber;

  RegisterRequestModel({
    required this.displayName,
    required this.email,
    required this.password,
    required this.rePassword,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    "displayName": displayName,
    "email": email,
    "password": password,
    "rePassword": rePassword,
    "phoneNumber": phoneNumber,
  };
}

class RegisterResponseModel {
  final String token;
  final String displayName;

  RegisterResponseModel({
    required this.token,
    required this.displayName,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      token: json['token'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "displayName": displayName,
  };
}