import 'package:equatable/equatable.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

class CurrencyLoaded extends CurrencyState {
  final Map<String, double> exchangeRates;
  final String baseCurrency;
  final DateTime lastUpdated;

  const CurrencyLoaded({
    required this.exchangeRates,
    required this.baseCurrency,
    required this.lastUpdated,
  });

  CurrencyLoaded copyWith({
    Map<String, double>? exchangeRates,
    String? baseCurrency,
    DateTime? lastUpdated,
  }) {
    return CurrencyLoaded(
      exchangeRates: exchangeRates ?? this.exchangeRates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [exchangeRates, baseCurrency, lastUpdated];
}

class CurrencyConversionResult extends CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime timestamp;

  const CurrencyConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        fromCurrency,
        toCurrency,
        originalAmount,
        convertedAmount,
        exchangeRate,
        timestamp,
      ];
}

class CurrencyError extends CurrencyState {
  final String message;
  final String? details;

  const CurrencyError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

class CurrencyRefreshing extends CurrencyState {
  final Map<String, double> currentRates;
  final String baseCurrency;

  const CurrencyRefreshing({
    required this.currentRates,
    required this.baseCurrency,
  });

  @override
  List<Object?> get props => [currentRates, baseCurrency];
}
