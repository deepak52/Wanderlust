// login request

import 'dart:convert';

LoginRequest loginRequestFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  String? userCode;
  String? password;

  LoginRequest({this.userCode, this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      LoginRequest(userCode: json["UserCode"], password: json["Password"]);

  Map<String, dynamic> toJson() => {"UserCode": userCode, "Password": password};
}

//login response

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String? accessToken;
  String? userId;
  String? email;
  bool? isAdmin;
  String? data;

  LoginResponse({
    this.accessToken,
    this.userId,
    this.email,
    this.isAdmin,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json["accessToken"],
    userId: json["userId"],
    email: json["email"],
    isAdmin: json["isAdmin"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "userId": userId,
    "email": email,
    "isAdmin": isAdmin,
    "data": data,
  };
}

// UserLoginRequest (for compatibility with existing LoginController)
UserLoginRequest userLoginRequestFromJson(String str) =>
    UserLoginRequest.fromJson(json.decode(str));

String userLoginRequestToJson(UserLoginRequest data) =>
    json.encode(data.toJson());

class UserLoginRequest {
  String? userCode;
  String? password;

  UserLoginRequest({this.userCode, this.password});

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      UserLoginRequest(userCode: json["UserCode"], password: json["Password"]);

  Map<String, dynamic> toJson() => {"UserCode": userCode, "Password": password};
}

// UserLoginResponse (for compatibility with existing LoginController)
UserLoginResponse userLoginResponseFromJson(String str) =>
    UserLoginResponse.fromJson(json.decode(str));

String userLoginResponseToJson(UserLoginResponse data) =>
    json.encode(data.toJson());

class UserLoginResponse {
  int? userId;
  String? userCode;
  String? userName;
  String? defaultCompCode;
  String? defaultBranchCode;
  int? defaultLocationId;
  String? designation;

  UserLoginResponse({
    this.userId,
    this.userCode,
    this.userName,
    this.defaultCompCode,
    this.defaultBranchCode,
    this.defaultLocationId,
    this.designation,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      UserLoginResponse(
        userId: json["UserID"],
        userCode: json["UserCode"],
        userName: json["UserName"],
        defaultCompCode: json["DefaultCompCode"],
        defaultBranchCode: json["DefaultBranchCode"],
        defaultLocationId: json["DefaultLocationID"],
        designation: json["Designation"],
      );

  Map<String, dynamic> toJson() => {
    "UserID": userId,
    "UserCode": userCode,
    "UserName": userName,
    "DefaultCompCode": defaultCompCode,
    "DefaultBranchCode": defaultBranchCode,
    "DefaultLocationID": defaultLocationId,
    "Designation": designation,
  };
}

// EmailResponse (for compatibility with existing LoginController)
EmailResponse emailResponseFromJson(String str) =>
    EmailResponse.fromJson(json.decode(str));

String emailResponseToJson(EmailResponse data) => json.encode(data.toJson());

class EmailResponse {
  String? message;
  String? emailId;

  EmailResponse({this.message, this.emailId});

  factory EmailResponse.fromJson(Map<String, dynamic> json) =>
      EmailResponse(message: json["message"], emailId: json["emailID"]);

  Map<String, dynamic> toJson() => {"message": message, "emailID": emailId};
}

// OtpRequest (for compatibility with existing LoginController)
OtpRequest otpRequestFromJson(String str) =>
    OtpRequest.fromJson(json.decode(str));

String otpRequestToJson(OtpRequest data) => json.encode(data.toJson());

class OtpRequest {
  Requestotp? request;
  int? pageMode;

  OtpRequest({this.request, this.pageMode});

  factory OtpRequest.fromJson(Map<String, dynamic> json) => OtpRequest(
    request:
        json["Request"] == null ? null : Requestotp.fromJson(json["Request"]),
    pageMode: json["PageMode"],
  );

  Map<String, dynamic> toJson() => {
    "Request": request?.toJson(),
    "PageMode": pageMode,
  };
}

class Requestotp {
  String? userCode;
  String? emailId;

  Requestotp({this.userCode, this.emailId});

  factory Requestotp.fromJson(Map<String, dynamic> json) =>
      Requestotp(userCode: json["UserCode"], emailId: json["EmailID"]);

  Map<String, dynamic> toJson() => {"UserCode": userCode, "EmailID": emailId};
}

// OtpResponse (for compatibility with existing LoginController)
OtpResponse otpResponseFromJson(String str) =>
    OtpResponse.fromJson(json.decode(str));

String otpResponseToJson(OtpResponse data) => json.encode(data.toJson());

class OtpResponse {
  String? verificationCode;

  OtpResponse({this.verificationCode});

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      OtpResponse(verificationCode: json["VerificationCode"]);

  Map<String, dynamic> toJson() => {"VerificationCode": verificationCode};
}

// VerifyOtpRequest (for compatibility with existing LoginController)
VerifyOtpRequest verifyOtpRequestFromJson(String str) =>
    VerifyOtpRequest.fromJson(json.decode(str));

String verifyOtpRequestToJson(VerifyOtpRequest data) =>
    json.encode(data.toJson());

class VerifyOtpRequest {
  VerifyOtpDetails? request;
  int? pageMode;

  VerifyOtpRequest({this.request, this.pageMode});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      VerifyOtpRequest(
        request:
            json["Request"] == null
                ? null
                : VerifyOtpDetails.fromJson(json["Request"]),
        pageMode: json["PageMode"],
      );

  Map<String, dynamic> toJson() => {
    "Request": request?.toJson(),
    "PageMode": pageMode,
  };
}

class VerifyOtpDetails {
  String? userCode;
  String? verificationCode;

  VerifyOtpDetails({this.userCode, this.verificationCode});

  factory VerifyOtpDetails.fromJson(Map<String, dynamic> json) =>
      VerifyOtpDetails(
        userCode: json["UserCode"],
        verificationCode: json["VerificationCode"],
      );

  Map<String, dynamic> toJson() => {
    "UserCode": userCode,
    "VerificationCode": verificationCode,
  };
}

// RefreshTokenRequest (for compatibility with existing LoginController)
RefreshTokenRequest refreshTokenRequestFromJson(String str) =>
    RefreshTokenRequest.fromJson(json.decode(str));

String refreshTokenRequestToJson(RefreshTokenRequest data) =>
    json.encode(data.toJson());

class RefreshTokenRequest {
  String? refreshToken;

  RefreshTokenRequest({this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      RefreshTokenRequest(refreshToken: json["refreshToken"]);

  Map<String, dynamic> toJson() => {"refreshToken": refreshToken};
}

// RefreshTokenResponse (for compatibility with existing LoginController)
RefreshTokenResponse refreshTokenResponseFromJson(String str) =>
    RefreshTokenResponse.fromJson(json.decode(str));

String refreshTokenResponseToJson(RefreshTokenResponse data) =>
    json.encode(data.toJson());

class RefreshTokenResponse {
  String? authToken;
  String? authExpiry;

  RefreshTokenResponse({this.authToken, this.authExpiry});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      RefreshTokenResponse(
        authToken: json["authToken"],
        authExpiry: json["authExpiry"],
      );

  Map<String, dynamic> toJson() => {
    "authToken": authToken,
    "authExpiry": authExpiry,
  };
}

// RefreshResponse (for compatibility with existing LoginController)
RefreshResponse refreshResponseFromJson(String str) =>
    RefreshResponse.fromJson(json.decode(str));

String refreshResponseToJson(RefreshResponse data) =>
    json.encode(data.toJson());

class RefreshResponse {
  String? authToken;
  String? authExpiry;

  RefreshResponse({this.authToken, this.authExpiry});

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        authToken: json["authToken"],
        authExpiry: json["authExpiry"],
      );

  Map<String, dynamic> toJson() => {
    "authToken": authToken,
    "authExpiry": authExpiry,
  };
}

// RefreshRequest (for compatibility with existing LoginController)
RefreshRequest refreshRequestFromJson(String str) =>
    RefreshRequest.fromJson(json.decode(str));

String refreshRequestToJson(RefreshRequest data) => json.encode(data.toJson());

class RefreshRequest {
  String? refreshToken;

  RefreshRequest({this.refreshToken});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      RefreshRequest(refreshToken: json["refreshToken"]);

  Map<String, dynamic> toJson() => {"refreshToken": refreshToken};
}
