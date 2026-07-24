// To parse this JSON data, do
//
//     final changePasswordRequest = changePasswordRequestFromJson(jsonString);

import 'dart:convert';

ChangePasswordRequest changePasswordRequestFromJson(String str) =>
    ChangePasswordRequest.fromJson(json.decode(str));

String changePasswordRequestToJson(ChangePasswordRequest data) =>
    json.encode(data.toJson());

class ChangePasswordRequest {
  String? companyCode;
  String? branchCode;
  int? userId;
  String? password;
  int? lastModUserId;
  int? counterId;

  ChangePasswordRequest({
    this.companyCode,
    this.branchCode,
    this.userId,
    this.password,
    this.lastModUserId,
    this.counterId,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      ChangePasswordRequest(
        companyCode: json["CompanyCode"],
        branchCode: json["BranchCode"],
        userId: json["UserID"],
        password: json["Password"],
        lastModUserId: json["LastModUserID"],
        counterId: json["CounterID"],
      );

  Map<String, dynamic> toJson() => {
    "CompanyCode": companyCode,
    "BranchCode": branchCode,
    "UserID": userId,
    "Password": password,
    "LastModUserID": lastModUserId,
    "CounterID": counterId,
  };
}
