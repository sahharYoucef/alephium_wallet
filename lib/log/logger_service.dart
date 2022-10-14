import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService instance = LoggerService._internal();
  late final Logger _logger;

  LoggerService._internal() {
    _logger = Logger();
  }

  void log(dynamic message, {Level level = Level.info}) {
    if (message == null && !kDebugMode) return;
    switch (level) {
      case Level.info:
        _logger.i(message);
        break;
      case Level.warning:
        _logger.w(message);
        break;
      case Level.error:
        _logger.e(message);
        break;
      case Level.verbose:
        _logger.v(message);
        break;
      case Level.wtf:
        _logger.wtf(message);
        break;
      case Level.debug:
        _logger.d(message);
        break;
      default:
        _logger.i(message);
        break;
    }
  }
}

enum Level {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
  nothing,
}
