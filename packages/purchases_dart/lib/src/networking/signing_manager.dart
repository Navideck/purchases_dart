import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:purchases_dart/src/networking/endpoint.dart';

// TODO: implement this for secure communication
// https://www.revenuecat.com/docs/customers/trusted-entitlements
class SigningManager {
  final String apiKey;
  SigningManager(this.apiKey);

  static const int _nonceBytesSize = 12;
  static const String _postParamsAlgo = 'sha256';
  static const int _postParamsSeparator = 0x00;

  bool shouldVerifyEndpoint(Endpoint endpoint) {
    return endpoint.supportsSignatureVerification();
  }

  String createRandomNonce() {
    final bytes = Uint8List(_nonceBytesSize);
    final secureRandom = Random.secure();
    for (var i = 0; i < _nonceBytesSize; i++) {
      bytes[i] = secureRandom.nextInt(256);
    }
    return base64.encode(bytes).trim();
  }

  String? getPostParamsForSigningHeaderIfNeeded(
    Endpoint endpoint,
    List<MapEntry<String, String>>? postFieldsToSign,
  ) {
    if (postFieldsToSign != null &&
        postFieldsToSign.isNotEmpty &&
        shouldVerifyEndpoint(endpoint)) {
      var bytes = <int>[];
      postFieldsToSign.asMap().forEach((index, pair) {
        if (index > 0) {
          bytes.add(_postParamsSeparator);
        }
        bytes.addAll(pair.value.codeUnits);
      });
      var digest = sha256.convert(bytes);
      var hashFields = digest.bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      return '${postFieldsToSign.map((pair) => pair.key).join(',')}:$_postParamsAlgo:$hashFields';
    } else {
      return null;
    }
  }
}
