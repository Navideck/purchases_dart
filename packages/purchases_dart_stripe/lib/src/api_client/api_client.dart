abstract class ApiClient {
  Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<Map<String, dynamic>?> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });
}
