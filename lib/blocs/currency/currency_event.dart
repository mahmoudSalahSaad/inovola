import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class LoadExchangeRates extends CurrencyEvent {
  final String baseCurrency;
  final List<String> targetCurrencies;

  const LoadExchangeRates({
    required this.baseCurrency,
    required this.targetCurrencies,
  });

  @override
  List<Object?> get props => [baseCurrency, targetCurrencies];
}

class ConvertCurrency extends CurrencyEvent {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ConvertCurrency({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, amount];
}

class RefreshExchangeRates extends CurrencyEvent {
  final String baseCurrency;

  const RefreshExchangeRates(this.baseCurrency);

  @override
  List<Object?> get props => [baseCurrency];
}

class ClearCurrencyCache extends CurrencyEvent {
  const ClearCurrencyCache();
}
