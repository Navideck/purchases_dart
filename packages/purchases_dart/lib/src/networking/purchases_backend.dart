import 'package:dio/dio.dart';
import 'package:purchases_dart/src/helper/purchase_error_code.dart';
import 'package:purchases_dart/src/model/raw_customer.dart';
import 'package:purchases_dart/src/model/raw_offerings.dart';
import 'package:purchases_dart/src/networking/endpoint.dart';
import 'package:purchases_dart/src/networking/rc_http_status_code.dart';
import 'package:purchases_dart/src/parser/customer_parser.dart';
import 'package:purchases_dart/src/parser/offering_parser.dart';
import 'package:purchases_dart/src/store_product_interface.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesBackend {
  late Dio _httpClient;
  late OfferingParser _offeringParser;
  late CustomerParser _customerParser;
  StoreProductInterface storeProduct;

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
    _offeringParser = OfferingParser(storeProduct);
    _customerParser = CustomerParser();
  }

  Future<CustomerInfo?> getCustomerInfo(String userId) async {
    final response = await _httpClient.get(GetCustomerInfo(userId).path);
    return _customerParser.createCustomer(RawCustomer.fromJson(response.data));
  }

  Future<Offerings?> getOfferings(String userId) async {
    final response = await _httpClient.get(GetOfferings(userId).path);
    return await _offeringParser.createOfferings(
      RawOfferings.fromJson(response.data),
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
    CustomerInfo? customerInfo = _customerParser.createCustomer(
      RawCustomer.fromJson(response.data),
    );
    if (customerInfo == null) {
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.UnknownError,
      ).toPlatformException();
    }
    return LogInResult(
      created: response.statusCode == RCHTTPStatusCodes.CREATED,
      customerInfo: customerInfo,
    );
  }

  Future<void> syncPurchases(String userId) async {
    // List<StoreTransaction> storeTransactions =
    await storeProduct.queryAllPurchases(userId);
    // final response = await _httpClient.get(SyncPurchases(userId).path);
    // print(response.data);
    // for (StoreTransaction transaction in storeTransactions) {
    // val extraHeaders = mapOf(
    //     "price_string" to receiptInfo.storeProduct?.price?.formatted,
    //     "marketplace" to marketplace,
    // ).filterNotNullValues()

    //  val body = mapOf(
    //       FETCH_TOKEN to purchaseToken,
    //       "product_ids" to receiptInfo.productIDs,
    //       "platform_product_ids" to receiptInfo.platformProductIds?.map { it.asMap },
    //       APP_USER_ID to appUserID,
    //       "is_restore" to isRestore,
    //       "presented_offering_identifier" to receiptInfo.offeringIdentifier,
    //       "observer_mode" to observerMode,
    //       "price" to receiptInfo.price,
    //       "currency" to receiptInfo.currency,
    //       "attributes" to subscriberAttributes.takeUnless { it.isEmpty() || appConfig.customEntitlementComputation },
    //       "normal_duration" to receiptInfo.duration,
    //       "store_user_id" to storeAppUserID,
    //       "pricing_phases" to receiptInfo.pricingPhases?.map { it.toMap() },
    //       "proration_mode" to (receiptInfo.replacementMode as? GoogleReplacementMode)?.asGoogleProrationMode?.name,
    //       "initiation_source" to initiationSource.postReceiptFieldValue,
    //       "paywall" to paywallPostReceiptData?.toMap(),
    //   ).filterNotNullValues()

    //   val postFieldsToSign = listOf(
    //       APP_USER_ID to appUserID,
    //       FETCH_TOKEN to purchaseToken,
    //   )

    //   _httpClient.post(
    //     PostReceipt().path,
    //     data: {},
    //   );
    // }
  }
}
