class UserProfileModel {
  final String displayName;
  final String userName;
  final String email;
  final String phoneNumber;

  UserProfileModel({
    required this.displayName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      displayName: json['displayName'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // Create a copy with updated fields
  UserProfileModel copyWith({
    String? displayName,
    String? userName,
    String? email,
    String? phoneNumber,
  }) {
    return UserProfileModel(
      displayName: displayName ?? this.displayName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class UpdateProfileRequestModel {
  final String displayName;
  final String userName;
  final String email;
  final String phoneNumber;

  UpdateProfileRequestModel({
    required this.displayName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
