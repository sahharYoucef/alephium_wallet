import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiError {
  late String message;
  late int statusCode;

  ApiError({required exception, StackTrace? trace}) {
    if (!kReleaseMode) {
      LoggerService.instance.log(exception.toString(), level: Level.error);
      LoggerService.instance.log(trace, level: Level.error);
    }
    if (exception is DioError) {
      LoggerService.instance.log(exception.response?.data, level: Level.error);
      if (exception.response?.data is Map<String, dynamic>) {
        message =
            exception.response?.data?["detail"] ?? kErrorMessageGenericError;
      } else {
        if (!kReleaseMode) {
          message =
              exception.response?.data.toString() ?? kErrorMessageGenericError;
        } else {
          message = kErrorMessageGenericError;
        }
      }
      statusCode = exception.response?.statusCode ?? 500;
    } else {
      if (!kReleaseMode) {
        message = exception.message;
      } else
        message = kErrorMessageGenericError;
      statusCode = 500;
    }
  }

  @override
  String toString() {
    return "${statusCode} - ${message}";
  }
}
