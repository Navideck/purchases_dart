class HTTPResult {
  static const String eTagHeaderName = 'X-RevenueCat-ETag';
  static const String signatureHeaderName = 'X-Signature';
  static const String requestTimeHeaderName = 'X-RevenueCat-Request-Time';

  final int responseCode;
  final String payload;
  final Origin origin;
  final DateTime? requestDate;
  final VerificationResult verificationResult;

  HTTPResult({
    required this.responseCode,
    required this.payload,
    required this.origin,
    this.requestDate,
    required this.verificationResult,
  });

  factory HTTPResult.fromJson(Map<String, dynamic> jsonMap) {
    Origin parseOrigin(dynamic data) {
      if (data == null) return Origin.cache;
      return Origin.values.firstWhere(
        (element) => element.name == data,
        orElse: () => Origin.cache,
      );
    }

    VerificationResult parseVerificationResult(dynamic data) {
      if (data == null) return VerificationResult.notRequested;
      return VerificationResult.values.firstWhere(
        (element) => element.name == data,
        orElse: () => VerificationResult.notRequested,
      );
    }

    return HTTPResult(
        responseCode: jsonMap['responseCode'],
        payload: jsonMap['payload'],
        origin: parseOrigin(jsonMap['origin']),
        requestDate: jsonMap.containsKey('requestDate')
            ? DateTime.fromMillisecondsSinceEpoch(jsonMap['requestDate'])
            : null,
        verificationResult:
            parseVerificationResult(jsonMap['verificationResult']));
  }

  Map<String, dynamic> toJson() => {
        'responseCode': responseCode,
        'payload': payload,
        'origin': origin.name,
        'requestDate': requestDate?.millisecondsSinceEpoch,
        'verificationResult': verificationResult.name,
      };
}

enum Origin {
  backend('BACKEND'),
  cache('CACHE');

  const Origin(this.name);
  final String name;
}

enum VerificationResult {
  notRequested('NOT_REQUESTED');

  const VerificationResult(this.name);
  final String name;
}
