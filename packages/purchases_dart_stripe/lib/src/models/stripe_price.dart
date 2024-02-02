class StripePrice {
  StripePrice({
    required this.id,
    required this.object,
    required this.active,
    required this.billingScheme,
    required this.created,
    required this.currency,
    required this.customUnitAmount,
    required this.livemode,
    required this.product,
    required this.taxBehavior,
    required this.type,
    required this.unitAmount,
    required this.unitAmountDecimal,
  });

  final String? id;
  final String? object;
  final bool? active;
  final String? billingScheme;
  final int? created;
  final String? currency;
  final dynamic customUnitAmount;
  final bool? livemode;
  final String? product;
  final String? taxBehavior;
  final String? type;
  final int? unitAmount;
  final String? unitAmountDecimal;

  factory StripePrice.fromJson(Map<String, dynamic> json) {
    return StripePrice(
      id: json["id"],
      object: json["object"],
      active: json["active"],
      billingScheme: json["billing_scheme"],
      created: json["created"],
      currency: json["currency"],
      customUnitAmount: json["custom_unit_amount"],
      livemode: json["livemode"],
      product: json["product"],
      taxBehavior: json["tax_behavior"],
      type: json["type"],
      unitAmount: json["unit_amount"],
      unitAmountDecimal: json["unit_amount_decimal"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "active": active,
        "billing_scheme": billingScheme,
        "created": created,
        "currency": currency,
        "custom_unit_amount": customUnitAmount,
        "livemode": livemode,
        "product": product,
        "tax_behavior": taxBehavior,
        "type": type,
        "unit_amount": unitAmount,
        "unit_amount_decimal": unitAmountDecimal,
      };
}
