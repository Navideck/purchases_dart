class RawProduct {
  RawProduct({
    required this.currentPrice,
    required this.defaultPurchaseOptionId,
    required this.defaultSubscriptionOptionId,
    required this.description,
    required this.identifier,
    required this.normalPeriodDuration,
    required this.productType,
    required this.purchaseOptions,
    required this.subscriptionOptions,
    required this.title,
  });

  final ProductPrice? currentPrice;
  final String? defaultPurchaseOptionId;
  final String? defaultSubscriptionOptionId;
  final String? description;
  final String? identifier;
  final String? normalPeriodDuration;
  final String? productType;
  final Map<String, ProductPurchaseOption>? purchaseOptions;
  final Map<String, ProductPurchaseOption>? subscriptionOptions;
  final String? title;

  factory RawProduct.fromJson(Map<String, dynamic> json) {
    return RawProduct(
      currentPrice: json["current_price"] == null
          ? null
          : ProductPrice.fromJson(json["current_price"]),
      defaultPurchaseOptionId: json["default_purchase_option_id"],
      defaultSubscriptionOptionId: json["default_subscription_option_id"],
      description: json["description"],
      identifier: json["identifier"],
      normalPeriodDuration: json["normal_period_duration"],
      productType: json["product_type"],
      purchaseOptions: _getPurchaseOptions(json["purchase_options"]),
      subscriptionOptions: _getPurchaseOptions(json["subscription_options"]),
      title: json["title"],
    );
  }

  static Map<String, ProductPurchaseOption> _getPurchaseOptions(dynamic data) {
    if (data == null || data is! Map) return {};
    Map<String, ProductPurchaseOption> purchaseOptions = {};
    for (var key in data.keys) {
      purchaseOptions[key] = ProductPurchaseOption.fromJson(data[key]);
    }
    return purchaseOptions;
  }

  Map<String, dynamic> toJson() => {
        "current_price": currentPrice?.toJson(),
        "default_purchase_option_id": defaultPurchaseOptionId,
        "default_subscription_option_id": defaultSubscriptionOptionId,
        "description": description,
        "identifier": identifier,
        "normal_period_duration": normalPeriodDuration,
        "product_type": productType,
        "purchase_options":
            purchaseOptions?.map((key, value) => MapEntry(key, value.toJson())),
        "subscription_options": subscriptionOptions
            ?.map((key, value) => MapEntry(key, value.toJson())),
        "title": title,
      };
}

class ProductPrice {
  ProductPrice({
    required this.amount,
    required this.amountMicros,
    required this.currency,
  });

  final int? amount;
  final int? amountMicros;
  final String? currency;

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      amount: json["amount"],
      amountMicros: json["amount_micros"],
      currency: json["currency"],
    );
  }

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "amount_micros": amountMicros,
        "currency": currency,
      };
}

class ProductPurchaseOption {
  ProductPurchaseOption({
    required this.base,
    required this.basePrice,
    required this.id,
    required this.introPrice,
    required this.priceId,
    required this.trial,
  });

  final PurchaseOptionBase? base;
  final ProductPrice? basePrice;
  final String? id;
  final dynamic introPrice;
  final String? priceId;
  final dynamic trial;

  factory ProductPurchaseOption.fromJson(Map<String, dynamic> json) {
    return ProductPurchaseOption(
      base: json["base"] == null
          ? null
          : PurchaseOptionBase.fromJson(json["base"]),
      basePrice: json["base_price"] == null
          ? null
          : ProductPrice.fromJson(json["base_price"]),
      id: json["id"],
      introPrice: json["intro_price"],
      priceId: json["price_id"],
      trial: json["trial"],
    );
  }

  Map<String, dynamic> toJson() => {
        "base": base?.toJson(),
        "id": id,
        "intro_price": introPrice,
        "price_id": priceId,
        "trial": trial,
      };
}

class PurchaseOptionBase {
  PurchaseOptionBase({
    required this.cycleCount,
    required this.periodDuration,
    required this.price,
  });

  final int? cycleCount;
  final String? periodDuration;
  final ProductPrice? price;

  factory PurchaseOptionBase.fromJson(Map<String, dynamic> json) {
    return PurchaseOptionBase(
      cycleCount: json["cycle_count"],
      periodDuration: json["period_duration"],
      price:
          json["price"] == null ? null : ProductPrice.fromJson(json["price"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "cycle_count": cycleCount,
        "period_duration": periodDuration,
        "price": price?.toJson(),
      };
}
