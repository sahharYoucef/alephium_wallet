import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:dio/dio.dart';

class ApiError {
  late String message;
  late int statusCode;

  ApiError({required exception, StackTrace? trace}) {
    print(trace);
    if (exception is DioError) {
      LoggerService.instance.log(exception.response?.data, level: Level.error);
      if (exception.response?.data is Map<String, dynamic>) {
        message =
            exception.response?.data?["detail"] ?? kErrorMessageGenericError;
      } else {
        message =
            exception.response?.data.toString() ?? kErrorMessageGenericError;
      }
      statusCode = exception.response?.statusCode ?? 500;
    } else {
      LoggerService.instance.log(exception.toString(), level: Level.error);
      message = exception.toString();
      statusCode = 500;
    }
  }

  @override
  String toString() {
    return message;
  }
}
