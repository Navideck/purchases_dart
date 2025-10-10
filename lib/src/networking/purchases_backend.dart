import 'package:dio/dio.dart';
import '../../purchases_dart.dart';
import '../helper/api_key_helper.dart';
import '../helper/purchase_error_code.dart';
import '../model/raw_product.dart';
import '../model/subscribe_attribute.dart';
import 'endpoint.dart';
import 'rc_http_status_code.dart';
import '../parser/customer_parser.dart';
import '../parser/offering_parser.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Backend for Purchases.
/// This class handles all the network requests.
class PurchasesBackend {
  late Dio _httpClient;
  OfferingParser? _offeringParser;
  CustomerParser? _customerParser;

  final String _rcBaseUrl = 'https://api.revenuecat.com/v1';
  final String _rcBillingBaseUrl = 'https://api.revenuecat.com/rcbilling/v1';
  late final bool isSandbox;

  PurchasesBackend({
    required String apiKey,
  }) {
    isSandbox = isWebBillingSandboxApiKey(apiKey);
    _httpClient = Dio(
      BaseOptions(
        baseUrl: _rcBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'X-Platform': 'web-billing',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
    _httpClient.interceptors.add(
      ErrorInterceptor(),
    );
    _offeringParser = OfferingParser();
    _customerParser = CustomerParser();
  }

  Future<CustomerInfo?> getCustomerInfo(
    String userId, {
    PurchasesHeader? headers,
  }) async {
    final response = await _httpClient.get(
      GetCustomerInfo(userId).path,
      options: headers?.dioOptions,
    );
    return _customerParser?.createCustomer(RawCustomer.fromJson(response.data));
  }

  Future<Offerings?> getOfferings(
    String userId, {
    PurchasesHeader? headers,
    String? currency,
  }) async {
    final rawOfferings = await getRawOfferings(userId, headers: headers);
    final rawProducts = await getRawProducts(
      userId,
      rawOfferings: rawOfferings,
      headers: headers,
      currency: currency,
    );
    return await _offeringParser?.createOfferings(rawOfferings, rawProducts);
  }

  Future<({Uri? production, Uri? sandbox})?> getWebBillingUrl(
      String userId, Package package) async {
    final rawOfferings = await getRawOfferings(userId);
    String offeringId = package.presentedOfferingContext.offeringIdentifier;
    for (var offering in rawOfferings.offerings) {
      if (offering.identifier == offeringId) {
        for (var rawPackage in offering.packages) {
          if (rawPackage.identifier == package.identifier) {
            String? sandboxUrl = offering.webCheckoutUrls?['sandbox'];
            String? productionUrl = rawPackage.webCheckoutUrl;
            Uri? productionUri;
            Uri? sandboxUri;
            if (sandboxUrl != null) {
              sandboxUri = Uri.parse(sandboxUrl);
              sandboxUri = sandboxUri.replace(queryParameters: {
                ...sandboxUri.queryParameters,
                'package_id': package.identifier,
              });
            }
            if (productionUrl != null) {
              productionUri = Uri.parse(productionUrl);
            }
            return (
              production: productionUri,
              sandbox: sandboxUri,
            );
          }
        }
      }
    }
    return null;
  }

  Future<RawOfferings> getRawOfferings(
    String userId, {
    PurchasesHeader? headers,
  }) async {
    final response = await _httpClient.get(
      GetOfferings(userId).path,
      options: headers?.dioOptions,
    );
    return RawOfferings.fromJson(response.data);
  }

  /// Set `currency` to `null` to use auto pick currency.
  Future<List<RawProduct>> getRawProducts(
    String userId, {
    required RawOfferings rawOfferings,
    PurchasesHeader? headers,
    required String? currency,
  }) async {
    Set<String> platformProductIdentifiers = {};
    for (var element in rawOfferings.offerings) {
      for (var package in element.packages) {
        String? platformProductIdentifier = package.platformProductIdentifier;
        if (platformProductIdentifier != null) {
          platformProductIdentifiers.add(platformProductIdentifier);
        }
      }
    }
    final response = await _httpClient.get(
      GetProducts(
        _rcBillingBaseUrl,
        userId,
        platformProductIdentifiers.toList(),
      ).path,
      queryParameters: {
        if (currency != null) 'currency': currency,
      },
      options: headers?.dioOptions,
    );

    var productDetails = response.data["product_details"];
    if (productDetails == null ||
        productDetails is! List ||
        productDetails.isEmpty) {
      return [];
    }

    return List<RawProduct>.from(
      productDetails.map((product) => RawProduct.fromJson(product)),
    );
  }

  Future<LogInResult> logIn({
    required String? oldAppUserId,
    required String newAppUserId,
  }) async {
    Response response = await _httpClient.post(LogIn().path, data: {
      'app_user_id': oldAppUserId,
      'new_app_user_id': newAppUserId,
    });
    if (response.data == null) {
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.UnknownError,
      ).toPlatformException();
    }
    CustomerInfo? customerInfo = _customerParser?.createCustomer(
      RawCustomer.fromJson(response.data),
    );
    if (customerInfo == null) {
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.UnknownError,
      ).toPlatformException();
    }
    return LogInResult(
      created: response.statusCode == RcHttpStatusCodes.CREATED,
      customerInfo: customerInfo,
    );
  }

  Future<void> postAttributes(
    String userId, {
    required Map<String, String?> attributesToSet,
    PurchasesHeader? headers,
  }) async {
    final attributes = attributesToSet.map(
      (key, value) => MapEntry(key, SubscriberAttribute(key, value)),
    );

    final backendMap = attributes.map(
      (key, attribute) => MapEntry(key, attribute.toBackendMap()),
    );

    await _httpClient.post(
      PostAttributes(userId).path,
      options: headers?.dioOptions,
      data: backendMap,
    );
  }
}
