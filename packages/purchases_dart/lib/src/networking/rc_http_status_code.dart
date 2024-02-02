// ignore_for_file: constant_identifier_names

class RCHTTPStatusCodes {
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int UNSUCCESSFUL = 300;
  static const int NOT_MODIFIED = 304;
  static const int BAD_REQUEST = 400;
  static const int NOT_FOUND = 404;
  static const int ERROR = 500;

  static bool isSuccessful(int statusCode) => statusCode < BAD_REQUEST;
  static bool isServerError(int statusCode) => statusCode >= ERROR;

  // Note: this means that all 4xx (except 404) are considered as successfully synced.
  // The reason is because it's likely due to a client error, so continuing to retry
  // won't yield any different results and instead kill pandas.
  static bool isSynced(int statusCode) =>
      isSuccessful(statusCode) ||
      !(isServerError(statusCode) || statusCode == NOT_FOUND);
}
