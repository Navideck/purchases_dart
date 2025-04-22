import 'package:dio/dio.dart';
import 'package:purchases_dart/purchases_dart.dart';
import 'package:purchases_dart/src/helper/purchase_error_code.dart';
import 'package:purchases_dart/src/model/subscribe_attribute.dart';
import 'package:purchases_dart/src/networking/endpoint.dart';
import 'package:purchases_dart/src/networking/rc_http_status_code.dart';
import 'package:purchases_dart/src/parser/customer_parser.dart';
import 'package:purchases_dart/src/parser/offering_parser.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Backend for Purchases.
/// This class handles all the network requests.
class PurchasesBackend {
  late Dio _httpClient;
  OfferingParser? _offeringParser;
  CustomerParser? _customerParser;
  StoreProductInterface? storeProduct;

  PurchasesBackend({
    required String apiKey,
    required this.storeProduct,
  }) {
    _httpClient = Dio(
      BaseOptions(
        baseUrl: 'https://api.revenuecat.com/v1',
        headers: {
          'X-Platform': 'stripe',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
      ),
    );
    _httpClient.interceptors.add(
      ErrorInterceptor(),
    );
    if (storeProduct != null) _offeringParser = OfferingParser(storeProduct!);
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
  }) async {
    final rawOfferings = await getRawOfferings(userId, headers: headers);
    return await _offeringParser?.createOfferings(rawOfferings);
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

  Future<void> syncPurchases(String userId) async {
    // List<StoreTransaction> storeTransactions =
    await storeProduct?.queryAllPurchases(userId);
    // final response = await _httpClient.get(SyncPurchases(userId).path);
  }
}
