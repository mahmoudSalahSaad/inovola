import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../utils/app_theme.dart';
import '../utils/bottom_sheet_utils.dart';
import '../utils/responsive_utils.dart';

class CurrencySelector extends StatelessWidget {
  final Currency selectedCurrency;
  final Function(Currency) onCurrencySelected;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  void _showCurrencyBottomSheet(BuildContext context) {
    BottomSheetUtils.showElegantBottomSheet(
      context: context,
      title: 'Select Currency',
      height: MediaQuery.of(context).size.height * 0.7,
      content: _buildCurrencyOptions(context),
    );
  }

  Widget _buildCurrencyOptions(BuildContext context) {
    // Group currencies by region
    final popularCurrencies = Currency.popularCurrencies.take(6).toList();
    final otherCurrencies = Currency.popularCurrencies.skip(6).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        BottomSheetUtils.buildSectionHeader(
          context: context,
          title: 'Popular Currencies',
          subtitle: 'Most commonly used currencies',
        ),
        ...popularCurrencies.map((currency) {
          return BottomSheetUtils.buildOptionTile(
            context: context,
            title: '${currency.code} - ${currency.name}',
            subtitle: _getCurrencyDescription(currency),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selectedCurrency.code == currency.code 
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedCurrency.code == currency.code 
                      ? AppTheme.primaryBlue
                      : AppTheme.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: selectedCurrency.code == currency.code 
                        ? AppTheme.primaryBlue
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            trailing: Text(
              currency.code,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selectedCurrency.code == currency.code 
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
              ),
            ),
            isSelected: selectedCurrency.code == currency.code,
            onTap: () {
              onCurrencySelected(currency);
              Navigator.of(context).pop();
            },
          );
        }),
        
        if (otherCurrencies.isNotEmpty) ...[
          const SizedBox(height: 16),
          BottomSheetUtils.buildSectionHeader(
            context: context,
            title: 'Other Currencies',
            subtitle: 'Additional currency options',
          ),
          ...otherCurrencies.map((currency) {
            return BottomSheetUtils.buildOptionTile(
              context: context,
              title: '${currency.code} - ${currency.name}',
              subtitle: _getCurrencyDescription(currency),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selectedCurrency.code == currency.code 
                      ? AppTheme.primaryBlue.withOpacity(0.2)
                      : AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedCurrency.code == currency.code 
                        ? AppTheme.primaryBlue
                        : AppTheme.dividerColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    currency.symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedCurrency.code == currency.code 
                          ? AppTheme.primaryBlue
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              trailing: Text(
                currency.code,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selectedCurrency.code == currency.code 
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                ),
              ),
              isSelected: selectedCurrency.code == currency.code,
              onTap: () {
                onCurrencySelected(currency);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  String _getCurrencyDescription(Currency currency) {
    // Add some context for popular currencies
    switch (currency.code) {
      case 'USD':
        return 'United States Dollar';
      case 'EUR':
        return 'European Union Euro';
      case 'GBP':
        return 'British Pound Sterling';
      case 'JPY':
        return 'Japanese Yen';
      case 'AUD':
        return 'Australian Dollar';
      case 'CAD':
        return 'Canadian Dollar';
      case 'CHF':
        return 'Swiss Franc';
      case 'CNY':
        return 'Chinese Yuan';
      case 'INR':
        return 'Indian Rupee';
      default:
        return currency.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCurrencyBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getCardPadding(context),
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    selectedCurrency.symbol,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCurrency.code,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to change',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
