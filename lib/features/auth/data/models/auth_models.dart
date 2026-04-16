class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'rememberMe': rememberMe};
  }
}

class LoginResponseModel {
  final String? token;
  final String? refreshToken;
  final int? tokenExpires;
  final Map<String, dynamic>? user;
  final bool? requiresOtp;
  final bool? requires2FA;
  final int? userId;
  final String? email;
  final String? message;

  LoginResponseModel({
    this.token,
    this.refreshToken,
    this.tokenExpires,
    this.user,
    this.requiresOtp,
    this.requires2FA,
    this.userId,
    this.email,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenExpires: json['tokenExpires'] as int?,
      user: json['user'] as Map<String, dynamic>?,
      requiresOtp: json['requiresOtp'] as bool?,
      requires2FA: json['requires2FA'] as bool?,
      userId: json['userId'] as int?,
      email: json['email'] as String?,
      message: json['message'] as String?,
    );
  }
}
