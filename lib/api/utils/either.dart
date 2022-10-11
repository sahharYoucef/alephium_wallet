import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:equatable/equatable.dart';

class Either<T> extends Equatable {
  late final ApiError? _error;
  late final T? _data;

  void setException(ApiError error) {
    _error = error;
  }

  Either({T? data, ApiError? error})
      : _data = data,
        _error = error;

  void setData(T data) {
    _data = data;
  }

  T? get getData => _data;

  ApiError? get getException => _error;

  bool get hasException => _error != null;

  bool get hasData => _data != null;

  @override
  List<Object?> get props => [_data, _error];
}
