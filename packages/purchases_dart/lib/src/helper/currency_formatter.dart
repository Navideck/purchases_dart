import 'package:purchases_dart/src/model/raw_product.dart';

String? formatWebBillingPrice(ProductPrice price) {
  int? amount = price.amount;
  String? currency = price.currency;
  if (amount == null || currency == null) {
    return null;
  }
  return _formatCurrency(amount, currency);
}

String? _formatCurrency(int amount, String currency) {
  if (_stripeZeroDecimalCurrencies.contains(currency.toLowerCase())) {
    return '${amount.toDouble()} $currency';
  }
  double amountDouble = amount / 100;
  String formattedAmount = amountDouble.toStringAsFixed(2);
  return switch (currency.toLowerCase()) {
    'usd' => '\$ $formattedAmount',
    'eur' => '€ $formattedAmount',
    _ => '$currency $formattedAmount',
  };
}

// https://stripe.com/docs/currencies#zero-decimal
List<String> _stripeZeroDecimalCurrencies = [
  'bif',
  'clp',
  'djf',
  'gnf',
  'jpy',
  'kmf',
  'krw',
  'mga',
  'pyg',
  'rwf',
  'vnd',
  'vuv',
  'xaf',
  'xof',
  'xpf',
];
