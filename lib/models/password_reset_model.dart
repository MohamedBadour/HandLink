class ForgotPasswordEmailRequest {
  final String email;

  ForgotPasswordEmailRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ForgotPasswordTelegramRequest {
  final String phoneNumber;

  ForgotPasswordTelegramRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber};
  }
}

class ForgotPasswordResponse {
  final String message;
  final int expiresIn;

  ForgotPasswordResponse({
    required this.message,
    required this.expiresIn,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

class VerifyResetCodeRequest {
  final String identifier;
  final String resetCode;
  final bool isEmail;

  VerifyResetCodeRequest({
    required this.identifier,
    required this.resetCode,
    required this.isEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'resetCode': resetCode,
      'isEmail': isEmail,
    };
  }
}

class VerifyResetCodeResponse {
  final bool success;
  final String message;
  final int expiresIn;

  VerifyResetCodeResponse({
    required this.success,
    required this.message,
    required this.expiresIn,
  });

  factory VerifyResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

class ResetPasswordRequest {
  final String identifier;
  final String newPassword;
  final bool isEmail;

  ResetPasswordRequest({
    required this.identifier,
    required this.newPassword,
    required this.isEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'newPassword': newPassword,
      'isEmail': isEmail,
    };
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;
  final int expiresIn;

  ResetPasswordResponse({
    required this.success,
    required this.message,
    required this.expiresIn,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}
