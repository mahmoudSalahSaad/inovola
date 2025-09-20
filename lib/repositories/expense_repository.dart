import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../models/expense_summary.dart';
import '../services/storage_service.dart';

class ExpenseRepository {
  late final Box<Expense> _expenseBox;

  ExpenseRepository() {
    _expenseBox = StorageService.expenseBox;
  }

  // Create
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  // Read
  List<Expense> getAllExpenses() {
    return _expenseBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Expense? getExpenseById(String id) {
    return _expenseBox.get(id);
  }

  // Update
  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  // Delete
  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  // Filter expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenseBox.values
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Filter expenses by category
  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _expenseBox.values
        .where((expense) => expense.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get paginated expenses
  PaginatedExpenses getPaginatedExpenses({
    int page = 1,
    int limit = 10,
    FilterPeriod? filterPeriod,
    ExpenseCategory? category,
  }) {
    List<Expense> allExpenses = getAllExpenses();

    // Apply filters
    if (filterPeriod != null && filterPeriod != FilterPeriod.all) {
      final dateRange = filterPeriod.dateRange;
      allExpenses = allExpenses
          .where((expense) =>
              expense.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              expense.date.isBefore(dateRange.end.add(const Duration(days: 1))))
          .toList();
    }

    if (category != null && category != ExpenseCategory.other) {
      allExpenses = allExpenses
          .where((expense) => expense.category == category)
          .toList();
    }

    final totalCount = allExpenses.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    final expenses = startIndex < totalCount
        ? allExpenses.sublist(
            startIndex,
            endIndex > totalCount ? totalCount : endIndex,
          )
        : <Expense>[];

    return PaginatedExpenses(
      expenses: expenses,
      currentPage: page,
      totalPages: totalPages,
      totalCount: totalCount,
      hasMore: page < totalPages,
    );
  }

  // Get expense summary
  ExpenseSummary getExpenseSummary({
    FilterPeriod filterPeriod = FilterPeriod.thisMonth,
    String baseCurrency = 'USD',
  }) {
    List<Expense> expenses;
    
    if (filterPeriod == FilterPeriod.all) {
      expenses = getAllExpenses();
    } else {
      final dateRange = filterPeriod.dateRange;
      expenses = getExpensesByDateRange(dateRange.start, dateRange.end);
    }

    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amountInUsd,
    );

    // For demo purposes, we'll calculate income as a percentage of expenses
    // In a real app, you'd track income separately
    final totalIncome = totalExpenses * 1.2; // 20% more than expenses

    final totalBalance = totalIncome - totalExpenses;

    // Group expenses by category
    final expensesByCategory = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0.0) + expense.amountInUsd;
    }

    // Get recent expenses (limited to last 5)
    final recentExpenses = expenses.take(5).toList();

    return ExpenseSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalBalance: totalBalance,
      recentExpenses: recentExpenses,
      filterPeriod: filterPeriod,
      expensesByCategory: expensesByCategory,
      baseCurrency: baseCurrency,
    );
  }

  // Search expenses
  List<Expense> searchExpenses(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _expenseBox.values
        .where((expense) =>
            expense.title.toLowerCase().contains(lowercaseQuery) ||
            expense.category.displayName.toLowerCase().contains(lowercaseQuery))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get total count
  int getTotalExpenseCount() {
    return _expenseBox.length;
  }

  // Clear all expenses
  Future<void> clearAllExpenses() async {
    await _expenseBox.clear();
  }
}
