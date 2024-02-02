class StripeProduct {
  StripeProduct({
    required this.id,
    required this.object,
    required this.active,
    required this.created,
    required this.defaultPrice,
    required this.description,
    required this.livemode,
    required this.metadata,
    required this.name,
    required this.packageDimensions,
    required this.shippable,
    required this.statementDescriptor,
    required this.taxCode,
    required this.type,
    required this.unitLabel,
    required this.updated,
    required this.url,
  });

  final String id;
  final String object;
  final bool active;
  final int created;
  final String defaultPrice;
  final String description;
  final bool livemode;
  final Map<String, dynamic> metadata;
  final String name;
  final String packageDimensions;
  final dynamic shippable;
  final String statementDescriptor;
  final String taxCode;
  final String type;
  final dynamic unitLabel;
  final int updated;
  final String url;

  factory StripeProduct.fromJson(Map<String, dynamic> json) {
    return StripeProduct(
      id: json["id"] ?? "",
      object: json["object"] ?? "",
      active: json["active"] ?? false,
      created: json["created"] ?? 0,
      defaultPrice: json["default_price"] ?? "",
      description: json["description"] ?? "",
      livemode: json["livemode"] ?? false,
      metadata: json["metadata"] ?? {},
      name: json["name"] ?? "",
      packageDimensions: json["package_dimensions"] ?? "",
      shippable: json["shippable"],
      statementDescriptor: json["statement_descriptor"] ?? "",
      taxCode: json["tax_code"] ?? "",
      type: json["type"] ?? "",
      unitLabel: json["unit_label"],
      updated: json["updated"] ?? 0,
      url: json["url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "active": active,
        "created": created,
        "default_price": defaultPrice,
        "description": description,
        "livemode": livemode,
        "metadata": metadata,
        "name": name,
        "package_dimensions": packageDimensions,
        "shippable": shippable,
        "statement_descriptor": statementDescriptor,
        "tax_code": taxCode,
        "type": type,
        "unit_label": unitLabel,
        "updated": updated,
        "url": url,
      };
}
