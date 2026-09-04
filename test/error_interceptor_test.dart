import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_dart/purchases_dart.dart';

class TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? rejectedError;

  @override
  void reject(DioException error, [bool isFake = false]) {
    rejectedError = error;
  }
}

void main() {
  group('ErrorInterceptor', () {
    late ErrorInterceptor interceptor;
    late TestErrorInterceptorHandler handler;

    setUp(() {
      interceptor = ErrorInterceptor();
      handler = TestErrorInterceptorHandler();
    });

    test('handles transformTimeout by rejecting with TransformTimeOutException', () {
      final requestOptions = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.transformTimeout,
      );

      interceptor.onError(err, handler);

      expect(handler.rejectedError, isA<TransformTimeOutException>());
      expect(handler.rejectedError.toString(), 'Transform Timed out, Please try again');
      expect(handler.rejectedError?.requestOptions, requestOptions);
    });

    test('handles other timeout types correctly', () {
      final requestOptions = RequestOptions(path: '/test');

      interceptor.onError(
        DioException(requestOptions: requestOptions, type: DioExceptionType.connectionTimeout),
        handler,
      );
      expect(handler.rejectedError, isA<ConnectionTimeOutException>());

      interceptor.onError(
        DioException(requestOptions: requestOptions, type: DioExceptionType.sendTimeout),
        handler,
      );
      expect(handler.rejectedError, isA<SendTimeOutException>());

      interceptor.onError(
        DioException(requestOptions: requestOptions, type: DioExceptionType.receiveTimeout),
        handler,
      );
      expect(handler.rejectedError, isA<ReceiveTimeOutException>());
    });
  });
}
