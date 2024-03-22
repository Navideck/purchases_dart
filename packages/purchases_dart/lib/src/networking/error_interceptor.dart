import 'package:dio/dio.dart';

/// ErrorInterceptor for handling errors in Dio,
/// and converting them to custom exceptions.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return handler.reject(
          ConnectionTimeOutException(err.requestOptions),
        );
      case DioExceptionType.sendTimeout:
        return handler.reject(
          SendTimeOutException(err.requestOptions),
        );
      case DioExceptionType.receiveTimeout:
        return handler.reject(
          ReceiveTimeOutException(err.requestOptions),
        );
      case DioExceptionType.connectionError:
        return handler.reject(
          NoInternetConnectionException(err.requestOptions),
        );
      case DioExceptionType.badCertificate:
        return handler.reject(
          CertificateVerificationFailed(err.requestOptions),
        );
      case DioExceptionType.badResponse:
        var responseData = err.response?.data;
        if (responseData != null) {
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: responseData.toString(),
            ),
          );
        }
        switch (err.response?.statusCode) {
          case 400:
            return handler.reject(
              BadRequestException(err.requestOptions),
            );
          case 401:
            return handler.reject(
              UnauthorizedException(err.requestOptions),
            );
          case 404:
            return handler.reject(
              NotFoundException(err.requestOptions),
            );
          case 409:
            return handler.reject(
              ConflictException(err.requestOptions),
            );
          case 500:
            return handler.reject(
              InternalServerErrorException(err.requestOptions),
            );
        }
        throw Exception(err.message);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      default:
        return handler.reject(err);
    }
  }
}

/// Custom Exceptions
class NoInternetConnectionException extends DioException {
  static String errorMessage =
      'No internet connection detected, please try again';

  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return errorMessage;
  }
}

class ConnectionTimeOutException extends DioException {
  ConnectionTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Connection Timed out, Please try again';
  }
}

class SendTimeOutException extends DioException {
  SendTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Send Timed out, Please try again';
  }
}

class ReceiveTimeOutException extends DioException {
  ReceiveTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Receive Timed out, Please try again';
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Internal server error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class CertificateVerificationFailed extends DioException {
  CertificateVerificationFailed(RequestOptions r) : super(requestOptions: r);

  static String errorMessage =
      'Certificate verification failed, please try again later.';

  @override
  String toString() {
    return errorMessage;
  }
}
