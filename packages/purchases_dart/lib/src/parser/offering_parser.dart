import 'package:purchases_dart/src/helper/currency_formatter.dart';
import 'package:purchases_dart/src/helper/extensions.dart';
import 'package:purchases_dart/src/model/raw_offerings.dart';
import 'package:purchases_dart/src/model/raw_product.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Parses a [RawOffering] into a [Offerings] object.
class OfferingParser {
  OfferingParser();

  Future<Offerings?> createOfferings(
    RawOfferings offeringRawResponse,
    List<RawProduct> rawProducts,
  ) async {
    List<Offering> offerings = [];
    Map<String, Offering> allOfferings = {};
    Offering? currentOffering;

    for (var rawOffering in offeringRawResponse.offerings) {
      Offering? data = await _createOffering(rawOffering, rawProducts);
      if (data != null) {
        offerings.add(data);
        allOfferings[data.identifier] = data;
        if (data.identifier == offeringRawResponse.currentOfferingId) {
          currentOffering = data;
        }
      }
    }
    return Offerings(allOfferings, current: currentOffering);
  }

  Future<Offering?> _createOffering(
    RawOffering rawOffering,
    List<RawProduct> rawProducts,
  ) async {
    String? offeringIdentifier = rawOffering.identifier;
    if (offeringIdentifier == null) return null;
    List<Package> packages = [];
    for (var package in rawOffering.packages) {
      Package? data = _createPackage(
        package,
        offeringIdentifier,
        rawProducts,
      );
      if (data != null) packages.add(data);
    }
    return Offering(
      offeringIdentifier,
      rawOffering.description ?? "No description",
      rawOffering.metadata,
      packages,
      lifetime: packages.ofType(PackageType.lifetime),
      annual: packages.ofType(PackageType.annual),
      sixMonth: packages.ofType(PackageType.sixMonth),
      threeMonth: packages.ofType(PackageType.threeMonth),
      twoMonth: packages.ofType(PackageType.twoMonth),
      monthly: packages.ofType(PackageType.monthly),
      weekly: packages.ofType(PackageType.weekly),
    );
  }

  Package? _createPackage(
    RawPackage rawPackage,
    String offeringIdentifier,
    List<RawProduct> rawProducts,
  ) {
    String? identifier = rawPackage.identifier;
    if (identifier == null) return null;
    String? platformProductId = rawPackage.platformProductIdentifier;
    if (platformProductId == null) return null;
    RawProduct? rawProduct = rawProducts.firstWhereOrNull(
      (element) => element.identifier == platformProductId,
    );
    if (rawProduct == null) return null;
    final offeringContext =
        PresentedOfferingContext(offeringIdentifier, null, null);

    ProductCategory productCategory = rawProduct.productType == "subscription"
        ? ProductCategory.subscription
        : ProductCategory.nonSubscription;

    ProductPurchaseOption? productPurchaseOption;

    if (productCategory == ProductCategory.subscription) {
      String? defaultSubscriptionOptionId =
          rawProduct.defaultSubscriptionOptionId;
      if (defaultSubscriptionOptionId != null) {
        productPurchaseOption =
            rawProduct.subscriptionOptions?[defaultSubscriptionOptionId];
      }
    } else {
      String? defaultPurchaseOptionId = rawProduct.defaultPurchaseOptionId;
      if (defaultPurchaseOptionId != null) {
        productPurchaseOption =
            rawProduct.purchaseOptions?[defaultPurchaseOptionId];
      }
    }

    ProductPrice? productPrice = rawProduct.currentPrice ??
        productPurchaseOption?.basePrice ??
        productPurchaseOption?.base?.price;

    if (productPrice == null) return null;

    double? price = productPrice.amount?.toDouble();
    String? currency = productPrice.currency;

    if (price == null || currency == null) {
      return null;
    }

    String? priceString = formatWebBillingPice(productPrice);

    return Package(
      identifier,
      rawPackage.packageType,
      StoreProduct(
        platformProductId,
        rawProduct.description ?? "",
        rawProduct.title ?? "",
        price,
        priceString ?? "",
        currency,
        presentedOfferingContext: offeringContext,
        productCategory: productCategory,
      ),
      offeringContext,
    );
  }
}

extension _PackageListExtension on List<Package> {
  Package? ofType(PackageType type) {
    return firstWhereOrNull((element) => element.packageType == type);
  }
}
