import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/currency.dart';

class CurrencyService {
  // Get API configuration from environment variables
  static String get _apiKey => dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '';
  static String get _baseUrl => dotenv.env['EXCHANGE_RATE_BASE_URL'] ?? 'https://v6.exchangerate-api.com/v6';
  
  final Map<String, ExchangeRate> _cache = {};

  Future<double> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    final exchangeRate = await getExchangeRate(fromCurrency, toCurrency);
    return amount * exchangeRate.rate;
  }

  Future<ExchangeRate> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    final cacheKey = '${fromCurrency}_$toCurrency';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cachedRate = _cache[cacheKey]!;
      if (!cachedRate.isExpired) {
        return cachedRate;
      }
    }

    try {
      // Fetch fresh rate from API
      final rate = await _fetchExchangeRate(fromCurrency, toCurrency);
      _cache[cacheKey] = rate;
      return rate;
    } catch (e) {
      // If API fails, try to return cached rate even if expired
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!;
      }
      
      // If no cache available, return fallback rate
      return ExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rate: _getFallbackRate(fromCurrency, toCurrency),
        timestamp: DateTime.now(),
      );
    }
  }

  Future<ExchangeRate> _fetchExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('Exchange rate API key not configured');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$_apiKey/latest/$fromCurrency'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Check if the API call was successful
      if (data['result'] == 'success') {
        final rates = data['conversion_rates'] as Map<String, dynamic>;
        
        if (rates.containsKey(toCurrency)) {
          final rate = (rates[toCurrency] as num).toDouble();
          return ExchangeRate(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            timestamp: DateTime.now(),
          );
        } else {
          throw Exception('Currency $toCurrency not found in exchange rates');
        }
      } else {
        final errorType = data['error-type'] ?? 'unknown';
        throw Exception('API Error: $errorType');
      }
    } else {
      throw Exception('Failed to fetch exchange rate: ${response.statusCode}');
    }
  }

  double _getFallbackRate(String fromCurrency, String toCurrency) {
    // Fallback rates for common currencies to USD
    const fallbackRates = {
      'USD': 1.0,
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'AUD': 1.35,
      'CAD': 1.25,
      'CHF': 0.92,
      'CNY': 6.45,
      'INR': 74.5,
    };

    final fromRate = fallbackRates[fromCurrency] ?? 1.0;
    final toRate = fallbackRates[toCurrency] ?? 1.0;
    
    if (fromCurrency == 'USD') {
      return toRate;
    } else if (toCurrency == 'USD') {
      return 1.0 / fromRate;
    } else {
      // Convert via USD
      return toRate / fromRate;
    }
  }

  Future<Map<String, double>> getMultipleRates(
    String baseCurrency,
    List<String> targetCurrencies,
  ) async {
    final rates = <String, double>{};
    
    for (final currency in targetCurrencies) {
      try {
        final rate = await getExchangeRate(baseCurrency, currency);
        rates[currency] = rate.rate;
      } catch (e) {
        rates[currency] = _getFallbackRate(baseCurrency, currency);
      }
    }
    
    return rates;
  }

  void clearCache() {
    _cache.clear();
  }

  // Mock service for testing
  static CurrencyService createMockService() {
    return _MockCurrencyService();
  }
}

class _MockCurrencyService extends CurrencyService {
  @override
  Future<double> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (fromCurrency == toCurrency) {
      return amount;
    }

    final rate = _getFallbackRate(fromCurrency, toCurrency);
    return amount * rate;
  }

  @override
  Future<ExchangeRate> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return ExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: _getFallbackRate(fromCurrency, toCurrency),
      timestamp: DateTime.now(),
    );
  }
}
