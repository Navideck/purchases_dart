import 'package:dio/dio.dart';
import 'package:purchases_dart/src/helper/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        throw ConnectionTimeOutException(err.requestOptions);
      case DioExceptionType.sendTimeout:
        throw SendTimeOutException(err.requestOptions);
      case DioExceptionType.receiveTimeout:
        throw ReceiveTimeOutException(err.requestOptions);
      case DioExceptionType.badResponse:
        var responseData = err.response?.data;
        if (responseData != null) {
          throw DioException(
            requestOptions: err.requestOptions,
            error: responseData.toString(),
          );
        }
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.requestOptions);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        throw Exception(err.message);
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
      default:
        if (err.error.toString().contains('SocketException')) {
          throw NoInternetConnectionException(err.requestOptions);
        } else if (err.error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
          throw CertificateVerificationFailed(err.requestOptions);
        } else {
          throw Exception(err.error);
        }
    }
    if (err.type == DioExceptionType.cancel) {
      Logger.logEvent(
        "RequestCanceled -> ${err.requestOptions.uri.path}",
        LogLevel.error,
      );
      return;
    }
    return handler.next(err);
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

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  static String errorMessage =
      'No internet connection detected, please try again.';

  @override
  String toString() {
    return errorMessage;
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
