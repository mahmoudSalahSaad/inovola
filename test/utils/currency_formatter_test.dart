import 'package:flutter_test/flutter_test.dart';
import 'package:inovola/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    group('formatAmount', () {
      test('should format USD amounts correctly', () {
        expect(CurrencyFormatter.formatAmount(100.0), '\$100.00');
        expect(CurrencyFormatter.formatAmount(1234.56), '\$1,234.56');
        expect(CurrencyFormatter.formatAmount(0.99), '\$0.99');
      });

      test('should format different currencies correctly', () {
        expect(CurrencyFormatter.formatAmount(100.0, currency: 'EUR'), '€100.00');
        expect(CurrencyFormatter.formatAmount(100.0, currency: 'GBP'), '£100.00');
        expect(CurrencyFormatter.formatAmount(100.0, currency: 'JPY'), '¥100.00');
        expect(CurrencyFormatter.formatAmount(100.0, currency: 'INR'), '₹100.00');
      });
    });

    group('formatAmountCompact', () {
      test('should format large amounts compactly', () {
        expect(CurrencyFormatter.formatAmountCompact(1000000.0), '\$1.0M');
        expect(CurrencyFormatter.formatAmountCompact(1500000.0), '\$1.5M');
        expect(CurrencyFormatter.formatAmountCompact(1000.0), '\$1.0K');
        expect(CurrencyFormatter.formatAmountCompact(1500.0), '\$1.5K');
      });

      test('should format small amounts normally', () {
        expect(CurrencyFormatter.formatAmountCompact(999.0), '\$999.00');
        expect(CurrencyFormatter.formatAmountCompact(100.0), '\$100.00');
      });

      test('should format compact amounts with different currencies', () {
        expect(CurrencyFormatter.formatAmountCompact(1000000.0, currency: 'EUR'), '€1.0M');
        expect(CurrencyFormatter.formatAmountCompact(1500.0, currency: 'GBP'), '£1.5K');
      });
    });

    group('parseAmount', () {
      test('should parse valid amount strings', () {
        expect(CurrencyFormatter.parseAmount('100.00'), 100.0);
        expect(CurrencyFormatter.parseAmount('1234.56'), 1234.56);
        expect(CurrencyFormatter.parseAmount('0.99'), 0.99);
      });

      test('should parse amounts with currency symbols', () {
        expect(CurrencyFormatter.parseAmount('\$100.00'), 100.0);
        expect(CurrencyFormatter.parseAmount('€1,234.56'), 1234.56);
        expect(CurrencyFormatter.parseAmount('£999.99'), 999.99);
      });

      test('should handle invalid input', () {
        expect(CurrencyFormatter.parseAmount(''), 0.0);
        expect(CurrencyFormatter.parseAmount('abc'), 0.0);
        expect(CurrencyFormatter.parseAmount('   '), 0.0);
      });

      test('should handle negative amounts', () {
        expect(CurrencyFormatter.parseAmount('-100.00'), -100.0);
        expect(CurrencyFormatter.parseAmount('-\$50.25'), -50.25);
      });
    });

    group('isValidAmount', () {
      test('should validate positive amounts', () {
        expect(CurrencyFormatter.isValidAmount('100.00'), true);
        expect(CurrencyFormatter.isValidAmount('\$50.25'), true);
        expect(CurrencyFormatter.isValidAmount('0.01'), true);
      });

      test('should reject zero and negative amounts', () {
        expect(CurrencyFormatter.isValidAmount('0.00'), false);
        expect(CurrencyFormatter.isValidAmount('-100.00'), false);
        expect(CurrencyFormatter.isValidAmount('0'), false);
      });

      test('should reject invalid input', () {
        expect(CurrencyFormatter.isValidAmount(''), false);
        expect(CurrencyFormatter.isValidAmount('abc'), false);
        expect(CurrencyFormatter.isValidAmount('   '), false);
      });
    });
  });
}
