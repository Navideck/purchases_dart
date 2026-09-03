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
        return handler.reject(err);
    }
  }
}

/// Custom Exceptions

/// Exception thrown when there is no internet connection available.
class NoInternetConnectionException extends DioException {
  static String errorMessage =
      'No internet connection detected, please try again';

  /// Creates a [NoInternetConnectionException] with the given request options.
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return errorMessage;
  }
}

/// Exception thrown when a connection timeout occurs.
class ConnectionTimeOutException extends DioException {
  /// Creates a [ConnectionTimeOutException] with the given request options.
  ConnectionTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Connection Timed out, Please try again';
  }
}

/// Exception thrown when a send timeout occurs.
class SendTimeOutException extends DioException {
  /// Creates a [SendTimeOutException] with the given request options.
  SendTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Send Timed out, Please try again';
  }
}

/// Exception thrown when a receive timeout occurs.
class ReceiveTimeOutException extends DioException {
  /// Creates a [ReceiveTimeOutException] with the given request options.
  ReceiveTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Receive Timed out, Please try again';
  }
}

/// Exception thrown when a bad request (HTTP 400) is received from the server.
///
/// This typically indicates that the request was malformed or contained invalid parameters.
class BadRequestException extends DioException {
  /// Creates a [BadRequestException] with the given request options.
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

/// Exception thrown when an internal server error (HTTP 500) occurs.
class InternalServerErrorException extends DioException {
  /// Creates an [InternalServerErrorException] with the given request options.
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Internal server error occurred, please try again later.';
  }
}

/// Exception thrown when a conflict (HTTP 409) occurs.
class ConflictException extends DioException {
  /// Creates a [ConflictException] with the given request options.
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

/// Exception thrown when an unauthorized request (HTTP 401) is made.
class UnauthorizedException extends DioException {
  /// Creates an [UnauthorizedException] with the given request options.
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

/// Exception thrown when a resource is not found (HTTP 404).
class NotFoundException extends DioException {
  /// Creates a [NotFoundException] with the given request options.
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

/// Exception thrown when SSL/TLS certificate verification fails.
///
/// This exception is raised when the server's certificate cannot be verified
/// during the SSL handshake process.
class CertificateVerificationFailed extends DioException {
  static String errorMessage =
      'Certificate verification failed, please try again later.';

  /// Creates a [CertificateVerificationFailed] exception with the given request options.
  CertificateVerificationFailed(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return errorMessage;
  }
}
