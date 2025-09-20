import 'package:equatable/equatable.dart';
import 'expense.dart';
import 'user.dart';

class ExpenseSummary extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;
  final List<Expense> recentExpenses;
  final FilterPeriod filterPeriod;
  final Map<ExpenseCategory, double> expensesByCategory;
  final String baseCurrency;

  const ExpenseSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
    required this.recentExpenses,
    required this.filterPeriod,
    required this.expensesByCategory,
    this.baseCurrency = 'USD',
  });

  ExpenseSummary copyWith({
    double? totalIncome,
    double? totalExpenses,
    double? totalBalance,
    List<Expense>? recentExpenses,
    FilterPeriod? filterPeriod,
    Map<ExpenseCategory, double>? expensesByCategory,
    String? baseCurrency,
  }) {
    return ExpenseSummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalBalance: totalBalance ?? this.totalBalance,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      filterPeriod: filterPeriod ?? this.filterPeriod,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }

  static const ExpenseSummary empty = ExpenseSummary(
    totalIncome: 0.0,
    totalExpenses: 0.0,
    totalBalance: 0.0,
    recentExpenses: [],
    filterPeriod: FilterPeriod.thisMonth,
    expensesByCategory: {},
    baseCurrency: 'USD',
  );

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        totalBalance,
        recentExpenses,
        filterPeriod,
        expensesByCategory,
        baseCurrency,
      ];
}

class PaginatedExpenses extends Equatable {
  final List<Expense> expenses;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;

  const PaginatedExpenses({
    required this.expenses,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
    this.isLoading = false,
  });

  PaginatedExpenses copyWith({
    List<Expense>? expenses,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginatedExpenses(
      expenses: expenses ?? this.expenses,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const PaginatedExpenses empty = PaginatedExpenses(
    expenses: [],
    currentPage: 0,
    totalPages: 0,
    totalCount: 0,
    hasMore: false,
    isLoading: false,
  );

  @override
  List<Object?> get props => [
        expenses,
        currentPage,
        totalPages,
        totalCount,
        hasMore,
        isLoading,
      ];
}
