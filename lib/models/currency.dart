import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }

  @override
  List<Object?> get props => [code, name, symbol];

  static const List<Currency> popularCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  ];
}

class ExchangeRate extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime timestamp;

  const ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.timestamp,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours > 1; // Consider rates expired after 1 hour
  }

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, timestamp];
}
