import 'dart:convert';

class AppBaseResponse<T> {
  List<ResponseError>? errors;
  T? data;
  String? message;
  bool? success;

  AppBaseResponse({this.errors, this.data, this.message, this.success});

  factory AppBaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return AppBaseResponse<T>(
      errors:
          json["errors"] == null
              ? null
              : List<ResponseError>.from(
                json["errors"].map((x) => ResponseError.fromJson(x)),
              ),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json["message"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      "errors":
          errors == null
              ? []
              : List<dynamic>.from(errors!.map((x) => x.toJson())),
      "data": data != null ? toJsonT(data as T) : null,
      "message": message,
      "success": success,
    };
  }
}

AppBaseResponse<T> misBaseResponseFromJson<T>(
  String str,
  T Function(dynamic) fromJsonT,
) {
  final Map<String, dynamic> jsonMap = json.decode(str);
  return AppBaseResponse<T>.fromJson(jsonMap, fromJsonT);
}

String misBaseResponseToJson<T>(
  AppBaseResponse<T> data,
  Object? Function(T) toJsonT,
) {
  final Map<String, dynamic> jsonMap = data.toJson(toJsonT);
  return json.encode(jsonMap);
}

class ResponseError {
  String? code;
  String? message;
  String? errorType;
  String? ruleConstSortOrder;

  ResponseError({
    this.code,
    this.message,
    this.errorType,
    this.ruleConstSortOrder,
  });

  factory ResponseError.fromJson(Map<String, dynamic> json) {
    return ResponseError(
      code: json["code"],
      message: json["message"],
      errorType: json["errorType"],
      ruleConstSortOrder: json["ruleConstSortOrder"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "message": message,
      "errorType": errorType,
      "ruleConstSortOrder": ruleConstSortOrder,
    };
  }
}
