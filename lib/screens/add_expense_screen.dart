import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../blocs/expense/expense_bloc.dart';
import '../blocs/expense/expense_event.dart';
import '../blocs/expense/expense_state.dart';
import '../blocs/currency/currency_bloc.dart';
import '../blocs/currency/currency_event.dart';
import '../blocs/currency/currency_state.dart';
import '../models/expense.dart';
import '../models/currency.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/responsive_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/category_selector.dart';
import '../widgets/currency_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.groceries;
  Currency _selectedCurrency = Currency.popularCurrencies.first;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  Map<String, double> _exchangeRates = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    
    // Load currency rates with USD as base for consistent conversion
    context.read<CurrencyBloc>().add(LoadExchangeRates(
      baseCurrency: 'USD',
      targetCurrencies: Currency.popularCurrencies
          .map((c) => c.code)
          .where((code) => code != 'USD')
          .toList(),
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = CurrencyFormatter.parseAmount(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final expense = Expense(
      id: 'expense_${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: amount,
      currency: _selectedCurrency.code,
      amountInUsd: 0.0, // Will be calculated by the bloc
      category: _selectedCategory,
      date: _selectedDate,
      receiptPath: _receiptImage?.path,
      createdAt: now,
      updatedAt: now,
    );

    context.read<ExpenseBloc>().add(AddExpense(expense));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseActionSuccess && state.action == 'adding') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is ExpenseActionError && state.action == 'adding') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
          ),
          BlocListener<CurrencyBloc, CurrencyState>(
            listener: (context, state) {
              if (state is CurrencyLoaded) {
                setState(() {
                  _exchangeRates = state.exchangeRates;
                });
              } else if (state is CurrencyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load exchange rates: ${state.message}'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories Section
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Amount Section
                _buildAmountSection(),

                const SizedBox(height: 24),

                // Date Section
                Text(
                  'Date',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _dateController,
                  hintText: 'Select date',
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Receipt Section
                Text(
                  'Attach Receipt',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReceiptSection(),

                const SizedBox(height: 24),

                // Title Section (Optional)
                Text(
                  'Description (Optional)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _titleController,
                  hintText: 'Add a note about this expense',
                  maxLines: 3,
                ),

                const SizedBox(height: 40),

                // Save Button
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    final isLoading = state is ExpenseActionLoading && state.action == 'adding';

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSave,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context) + 4),
          
          // Amount Input with Currency
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                // Currency Symbol Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Text(
                    _selectedCurrency.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                      fontSize: 20,
                    ),
                  ),
                ),
                
                // Amount Input
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Amount is required';
                      }
                      final amount = CurrencyFormatter.parseAmount(value!);
                      if (amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Real-time formatting could be added here
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Currency Selector
          Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                color: AppTheme.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Currency',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          CurrencySelector(
            selectedCurrency: _selectedCurrency,
            onCurrencySelected: (currency) {
              setState(() {
                _selectedCurrency = currency;
              });
              // Load exchange rates with USD as base for consistent conversion
              context.read<CurrencyBloc>().add(LoadExchangeRates(
                baseCurrency: 'USD',
                targetCurrencies: Currency.popularCurrencies
                    .map((c) => c.code)
                    .where((code) => code != 'USD')
                    .toList(),
              ));
            },
          ),
          
          // Amount Preview/Conversion (if different from USD)
          if (_selectedCurrency.code != 'USD' && _amountController.text.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            BlocBuilder<CurrencyBloc, CurrencyState>(
              builder: (context, currencyState) {
                final isLoading = currencyState is CurrencyLoading;
                final hasError = currencyState is CurrencyError;
                final usdEquivalent = _getUSDEquivalent();
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasError 
                        ? AppTheme.errorColor.withOpacity(0.05)
                        : AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasError 
                          ? AppTheme.errorColor.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ] else ...[
                        Icon(
                          hasError 
                              ? Icons.error_outline_rounded
                              : Icons.currency_exchange_rounded,
                          color: hasError 
                              ? AppTheme.errorColor
                              : AppTheme.primaryBlue,
                          size: 16,
                        ),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasError 
                                  ? 'Unable to load exchange rate'
                                  : isLoading
                                      ? 'Loading exchange rate...'
                                      : 'Approximately \$$usdEquivalent USD',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: hasError 
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isLoading && !hasError && _exchangeRates.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Exchange rate updated ${_getLastUpdateTime()}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _getLastUpdateTime() {
    return 'just now'; // In a real app, you'd get this from the API response
  }

  String _getUSDEquivalent() {
    try {
      final amount = CurrencyFormatter.parseAmount(_amountController.text);
      if (amount <= 0) return '0.00';
      
      // If already USD, return the same amount
      if (_selectedCurrency.code == 'USD') {
        return amount.toStringAsFixed(2);
      }
      
      // Use real exchange rates if available
      if (_exchangeRates.isNotEmpty) {
        // Get the rate from selected currency to USD
        // The API returns rates from base currency to others
        // If USD is base, we get direct rates. If not, we need to calculate
        double usdAmount;
        
        if (_exchangeRates.containsKey('USD')) {
          // USD rate exists in our rates (base is not USD)
          final usdRate = _exchangeRates['USD']!;
          usdAmount = amount * usdRate;
        } else {
          // Base currency is USD, so we need to convert from selected currency
          // This means we need the inverse rate
          final selectedCurrencyRate = _exchangeRates[_selectedCurrency.code];
          if (selectedCurrencyRate != null && selectedCurrencyRate > 0) {
            usdAmount = amount / selectedCurrencyRate;
          } else {
            return 'N/A';
          }
        }
        
        return usdAmount.toStringAsFixed(2);
      }
      
      // Fallback to placeholder if no rates available
      return 'Loading...';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildReceiptSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
          style: BorderStyle.solid,
        ),
      ),
      child: _receiptImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _receiptImage!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _receiptImage = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Image',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
