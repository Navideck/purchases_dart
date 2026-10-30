import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_dart/src/parser/virtual_currencies_parser.dart';

void main() {
  test('parses the subscriber virtual currencies response', () {
    final result = VirtualCurrenciesParser.parse({
      'virtual_currencies': {
        'GLD': {
          'balance': 100,
          'name': 'Gold',
          'code': 'GLD',
          'serverDescription': 'Premium currency',
        },
      },
    });

    expect(result.all['GLD']?.balance, 100);
    expect(result.all['GLD']?.name, 'Gold');
    expect(result.all['GLD']?.serverDescription, 'Premium currency');
  });

  test('rejects an invalid response', () {
    expect(
      () => VirtualCurrenciesParser.parse({}),
      throwsA(isA<StateError>()),
    );
  });
}
