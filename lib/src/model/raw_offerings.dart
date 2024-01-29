import 'package:purchases_flutter/models/package_wrapper.dart';

class RawOfferings {
  RawOfferings({
    required this.currentOfferingId,
    required this.offerings,
  });

  final String? currentOfferingId;
  final List<RawOffering> offerings;

  factory RawOfferings.fromJson(Map<String, dynamic> json) {
    return RawOfferings(
      currentOfferingId: json["current_offering_id"],
      offerings: json["offerings"] == null
          ? []
          : List<RawOffering>.from(
              json["offerings"]!.map((x) => RawOffering.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "current_offering_id": currentOfferingId,
        "offerings": offerings.map((x) => x.toJson()).toList(),
      };
}

class RawOffering {
  RawOffering({
    required this.description,
    required this.identifier,
    required this.metadata,
    required this.packages,
  });

  final String? description;
  final String? identifier;
  final Map<String, Object> metadata;
  final List<RawPackage> packages;

  factory RawOffering.fromJson(Map<String, dynamic> json) {
    return RawOffering(
      description: json["description"],
      identifier: json["identifier"],
      metadata: json["metadata"] ?? {},
      packages: json["packages"] == null
          ? []
          : List<RawPackage>.from(
              json["packages"]!.map((x) => RawPackage.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "identifier": identifier,
        "metadata": metadata,
        "packages": packages.map((x) => x.toJson()).toList(),
      };
}

class RawPackage {
  RawPackage({
    required this.identifier,
    required this.platformProductIdentifier,
    required this.platformProductPlanIdentifier,
  });

  final String? identifier;
  final String? platformProductIdentifier;
  final String? platformProductPlanIdentifier;

  factory RawPackage.fromJson(Map<String, dynamic> json) {
    return RawPackage(
      identifier: json["identifier"],
      platformProductIdentifier: json["platform_product_identifier"],
      platformProductPlanIdentifier: json["platform_product_plan_identifier"],
    );
  }

  PackageType get packageType {
    return switch (identifier) {
      '\$rc_lifetime' => PackageType.lifetime,
      '\$rc_annual' => PackageType.annual,
      '\$rc_six_month' => PackageType.sixMonth,
      '\$rc_three_month' => PackageType.threeMonth,
      '\$rc_two_month' => PackageType.twoMonth,
      '\$rc_monthly' => PackageType.monthly,
      '\$rc_weekly' => PackageType.weekly,
      _ => PackageType.unknown,
    };
  }

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "platform_product_identifier": platformProductIdentifier,
        "platform_product_plan_identifier": platformProductPlanIdentifier,
      };
}
