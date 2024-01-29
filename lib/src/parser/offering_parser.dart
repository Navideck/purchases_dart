import 'package:purchases_dart/src/model/raw_offerings.dart';
import 'package:purchases_dart/src/store/store_product_interface.dart';
import 'package:purchases_flutter/object_wrappers.dart';

/// Parses a [RawOffering] into a [Offerings] object.
class OfferingParser {
  final StoreProductInterface _storeProduct;
  OfferingParser(this._storeProduct);

  Future<Offerings?> createOfferings(
    RawOfferings offeringRawResponse,
  ) async {
    List<Offering> offerings = [];
    Map<String, Offering> allOfferings = {};
    Offering? currentOffering;

    for (var rawOffering in offeringRawResponse.offerings) {
      Offering? data = await _createOffering(rawOffering);
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

  Future<Offering?> _createOffering(RawOffering rawOffering) async {
    String? offeringIdentifier = rawOffering.identifier;
    if (offeringIdentifier == null) return null;
    List<Package> packages = [];
    for (var package in rawOffering.packages) {
      Package? data = await _createPackage(package, offeringIdentifier);
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

  Future<Package?> _createPackage(
    RawPackage rawPackage,
    String offeringIdentifier,
  ) async {
    String? identifier = rawPackage.identifier?.replaceFirst("\$", "");
    if (identifier == null) return null;
    String? platformProductId = rawPackage.platformProductIdentifier;
    if (platformProductId == null) return null;
    var product = await _storeProduct.getStoreProducts(platformProductId);
    if (product == null) return null;
    return Package(
      identifier,
      rawPackage.packageType,
      product,
      offeringIdentifier,
    );
  }
}

extension _PackageListExtension on List<Package> {
  Package? ofType(PackageType type) {
    return firstWhereOrNull((element) => element.packageType == type);
  }
}
