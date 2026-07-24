import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../view/widget/dialog/http_error_list_dialog.dart';
import 'app_message.dart';
import 'app_string.dart';
import 'enum.dart';
import 'navigation.dart';
import 'route.dart' show loginPageRoute;
import 'single_app.dart';
import 'core/environment/env.dart';
import 'core/base/app_base_response.dart';

class HttpService extends GetxService {
  final MyApplication myApplication = Get.find<MyApplication>();

  Future<dynamic> get({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppEnvironment.config.baseApiurl}$endpoint');
    appLog('http GET: url:$url', logging: Logging.info);
    try {
      headers ??= await _getHeaders();
      appLog('http: headers:$headers', logging: Logging.info);
      final response = await http.get(url, headers: headers);
      appLog('http: response:${response.body}', logging: Logging.info);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('$exceptionMsg $e');
    }
  }

  String? _getToken() {
    if (myApplication.preferenceHelper == null) return null;
    return myApplication.preferenceHelper!.getString(accessTokenKey);
  }

  Uri _buildUri(String endpoint, {bool requiresToken = true}) {
    final baseUrl = AppEnvironment.config.baseApiurl;
    final uri = Uri.parse('$baseUrl$endpoint');

    if (!requiresToken) return uri;

    final token = _getToken();
    if (token == null || token.isEmpty) return uri;

    return uri.replace(
      queryParameters: {...uri.queryParameters, 'token': token},
    );
  }

  Future<AppBaseResponse<T>?> getService<T>({
    required String endpoint,
    Map<String, String>? headers,
    required T Function(dynamic) fromJsonT,
    bool requiresToken = true,
  }) async {
    final uri = _buildUri(endpoint, requiresToken: requiresToken);

    appLog('http GET: url:$uri', logging: Logging.info);

    try {
      headers ??= await _getHeaders();

      final response = await http.get(uri, headers: headers);

      appLog('http: response:${response.body}', logging: Logging.info);

      if (response.statusCode == 200) {
        return misBaseResponseFromJson<T>(response.body, fromJsonT);
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('$exceptionMsg $e');
    }
  }

  Future<dynamic> post({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppEnvironment.config.baseApiurl}$endpoint');
    appLog('http POST: url:$url', logging: Logging.info);
    try {
      headers ??= await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      appLog('http: headers:$headers', logging: Logging.info);
      appLog('http: response:${response.body}', logging: Logging.info);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('$exceptionMsg $e');
    }
  }

  Future<AppBaseResponse<T>?> postService<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJsonT,
    bool ignoreError = false,
    bool requiresToken = true,
  }) async {
    final uri = _buildUri(endpoint, requiresToken: requiresToken);

    appLog('http POST: url:$uri', logging: Logging.info);

    try {
      headers ??= await _getHeaders();

      final encodedBody = data != null ? jsonEncode(data) : null;

      final response = await http.post(
        uri,
        headers: headers,
        body: encodedBody,
      );

      appLog('http: body:${encodedBody ?? ''}', logging: Logging.info);
      appLog(
        'http: response: ${response.statusCode} ${response.body}',
        logging: Logging.info,
      );

      if (response.statusCode == 200) {
        final baseResponse = misBaseResponseFromJson<T>(
          response.body,
          fromJsonT,
        );

        if (!ignoreError &&
            baseResponse.errors != null &&
            baseResponse.errors!.isNotEmpty) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => showErrorSnackbar(
              message: baseResponse.errors!.first.message ?? 'Error',
            ),
          );
        }

        return baseResponse;
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('$exceptionMsg $e');
    }
  }

  T safeFindOrLazyPut<T>(T Function() creator) {
    if (!Get.isRegistered<T>()) {
      Get.lazyPut(creator);
    }
    return Get.find<T>();
  }

  Future<Map<String, String>> _getHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception("$badRequest: ${response.body}");
      case 401:
        toastMessage(failedAuthenticationMsg.tr);
        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToAndRemoveAll(loginPageRoute);
        });
        throw Exception("$unauthorized: ${response.body}");

      case 403:
        throw Exception("$forbidden: ${response.body}");
      case 404:
        throw Exception("$notFound: ${response.body}");
      case 500:
        throw Exception("$serverError: ${response.body}");
      default:
        throw Exception("$unknownError: ${response.body}");
    }
  }

  void showErroListDialog(List<ResponseError> errors) {
    showDialog(
      context: Get.context!,
      builder: (context) => HttpErrorListDialog(errors: errors),
    );
  }
}
