import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/currency.dart';
import '../../services/currency_service.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService;

  CurrencyBloc({
    required CurrencyService currencyService,
  })  : _currencyService = currencyService,
        super(const CurrencyInitial()) {
    
    on<LoadExchangeRates>(_onLoadExchangeRates);
    on<ConvertCurrency>(_onConvertCurrency);
    on<RefreshExchangeRates>(_onRefreshExchangeRates);
    on<ClearCurrencyCache>(_onClearCurrencyCache);
  }

  Future<void> _onLoadExchangeRates(
    LoadExchangeRates event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(const CurrencyLoading());

      final exchangeRates = await _currencyService.getMultipleRates(
        event.baseCurrency,
        event.targetCurrencies,
      );

      emit(CurrencyLoaded(
        exchangeRates: exchangeRates,
        baseCurrency: event.baseCurrency,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(CurrencyError(
        message: 'Failed to load exchange rates',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onConvertCurrency(
    ConvertCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(const CurrencyLoading());

      final convertedAmount = await _currencyService.convertCurrency(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        amount: event.amount,
      );

      final exchangeRate = await _currencyService.getExchangeRate(
        event.fromCurrency,
        event.toCurrency,
      );

      emit(CurrencyConversionResult(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        originalAmount: event.amount,
        convertedAmount: convertedAmount,
        exchangeRate: exchangeRate.rate,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(CurrencyError(
        message: 'Failed to convert currency',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshExchangeRates(
    RefreshExchangeRates event,
    Emitter<CurrencyState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is CurrencyLoaded) {
      emit(CurrencyRefreshing(
        currentRates: currentState.exchangeRates,
        baseCurrency: currentState.baseCurrency,
      ));
    } else {
      emit(const CurrencyLoading());
    }

    try {
      // Clear cache to force fresh data
      _currencyService.clearCache();

      // Get popular currencies for refresh
      final targetCurrencies = Currency.popularCurrencies
          .map((currency) => currency.code)
          .where((code) => code != event.baseCurrency)
          .toList();

      final exchangeRates = await _currencyService.getMultipleRates(
        event.baseCurrency,
        targetCurrencies,
      );

      emit(CurrencyLoaded(
        exchangeRates: exchangeRates,
        baseCurrency: event.baseCurrency,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(CurrencyError(
        message: 'Failed to refresh exchange rates',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onClearCurrencyCache(
    ClearCurrencyCache event,
    Emitter<CurrencyState> emit,
  ) async {
    _currencyService.clearCache();
    emit(const CurrencyInitial());
  }
}
