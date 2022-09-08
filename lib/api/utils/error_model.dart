class ErrorModel {
  int? errorCode;
  String? errorMessageKey;
  String? errorMessage;

  ErrorModel(this.errorCode, this.errorMessageKey, this.errorMessage);

  @override
  String toString() {
    return 'ErrorModel{errorMessageKey: $errorMessageKey, errorMessage: $errorMessage, errorCode: $errorCode}';
  }
}
