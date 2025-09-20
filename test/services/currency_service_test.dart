import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inovola/services/currency_service.dart' show CurrencyService;

void main() {
  group('CurrencyService', () {
    late CurrencyService currencyService;

    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      currencyService = CurrencyService();
    });

    test('should convert currency using exchange rate API', () async {
      // Test converting USD to EUR
      final result = await currencyService.convertCurrency(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        amount: 100.0,
      );

      expect(result, isA<double>());
      expect(result, greaterThan(0));
      expect(result, isNot(equals(100.0))); // Should be different from original amount
    });

    test('should return same amount for same currency conversion', () async {
      final result = await currencyService.convertCurrency(
        fromCurrency: 'USD',
        toCurrency: 'USD',
        amount: 100.0,
      );

      expect(result, equals(100.0));
    });

    test('should get exchange rate between currencies', () async {
      final exchangeRate = await currencyService.getExchangeRate('USD', 'EUR');

      expect(exchangeRate.fromCurrency, equals('USD'));
      expect(exchangeRate.toCurrency, equals('EUR'));
      expect(exchangeRate.rate, isA<double>());
      expect(exchangeRate.rate, greaterThan(0));
      expect(exchangeRate.timestamp, isA<DateTime>());
    });

    test('should get multiple exchange rates', () async {
      final rates = await currencyService.getMultipleRates(
        'USD',
        ['EUR', 'GBP', 'JPY'],
      );

      expect(rates, hasLength(3));
      expect(rates['EUR'], isA<double>());
      expect(rates['GBP'], isA<double>());
      expect(rates['JPY'], isA<double>());
    });

    test('should use fallback rates when API fails', () async {
      // Test with invalid currency to trigger fallback
      final result = await currencyService.convertCurrency(
        fromCurrency: 'INVALID',
        toCurrency: 'USD',
        amount: 100.0,
      );

      expect(result, isA<double>());
      expect(result, greaterThan(0));
    });
  });
}