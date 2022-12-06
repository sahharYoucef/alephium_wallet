import 'package:alephium_wallet/log/logger_service.dart';
import 'package:dio/dio.dart';

class ApiInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;

  ApiInterceptor(this.dio);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerService.instance
        .log("${options.method} : ${options.uri}", level: Level.debug);
    LoggerService.instance.log(options.data, level: Level.debug);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    LoggerService.instance.log(err.error, level: Level.debug);

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.instance.log(response.data, level: Level.debug);
    super.onResponse(response, handler);
  }
}
