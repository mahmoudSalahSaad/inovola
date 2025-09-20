import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatAmount(double amount, {String? currency}) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency ?? 'USD'),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatAmountCompact(double amount, {String? currency}) {
    final symbol = _getCurrencySymbol(currency ?? 'USD');
    
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount, currency: currency);
    }
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF ';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return '$currency ';
    }
  }

  static double parseAmount(String input) {
    // Remove currency symbols and spaces
    final cleaned = input
        .replaceAll(RegExp(r'[^\d.-]'), '')
        .trim();
    
    if (cleaned.isEmpty) return 0.0;
    
    return double.tryParse(cleaned) ?? 0.0;
  }

  static bool isValidAmount(String input) {
    final amount = parseAmount(input);
    return amount > 0;
  }
}
