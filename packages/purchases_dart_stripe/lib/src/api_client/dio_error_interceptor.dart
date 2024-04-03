import 'package:dio/dio.dart';

/// [StripeDioErrorInterceptor] used to handle errors from dio.
class StripeDioErrorInterceptor extends Interceptor {
  StripeDioErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return handler.reject(err.toCustom("Connection Timeout"));
      case DioExceptionType.sendTimeout:
        return handler.reject(err.toCustom("Send Timeout"));
      case DioExceptionType.receiveTimeout:
        return handler.reject(err.toCustom("Receive Timeout"));
      case DioExceptionType.badResponse:
        var responseData = err.response?.data;
        if (responseData != null) {
          return handler.reject(err.toCustom(responseData.toString()));
        } else if (err.message != null) {
          return handler.reject(err.toCustom(err.message!));
        }
        return handler.reject(err.toCustom("Bad Response"));
      case DioExceptionType.cancel:
        return handler.next(err);
      case DioExceptionType.unknown:
      default:
        if (err.error.toString().contains('SocketException')) {
          return handler.reject(
            err.toCustom("Please check your internet connection"),
          );
        } else if (err.error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
          return handler.reject(
            err.toCustom("Certificate verification failed"),
          );
        } else {
          return handler.next(err);
        }
    }
  }
}

extension _DioExt on DioException {
  DioCustomException toCustom(String errorMessage) {
    return DioCustomException(requestOptions, errorMessage);
  }
}

class DioCustomException extends DioException {
  String errorMessage;
  DioCustomException(requestOptions, this.errorMessage)
      : super(requestOptions: requestOptions);

  @override
  String toString() {
    return errorMessage;
  }
}
