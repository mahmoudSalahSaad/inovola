import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/expense_summary.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/currency_service.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final UserRepository _userRepository;
  final CurrencyService _currencyService;

  static const int _pageSize = 10;

  ExpenseBloc({
    required ExpenseRepository expenseRepository,
    required UserRepository userRepository,
    required CurrencyService currencyService,
  })  : _expenseRepository = expenseRepository,
        _userRepository = userRepository,
        _currencyService = currencyService,
        super(const ExpenseInitial()) {
    
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<SearchExpenses>(_onSearchExpenses);
    on<FilterExpenses>(_onFilterExpenses);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseLoading());

      final filterPeriod = event.filterPeriod ?? _userRepository.getFilterPeriod();

      // Get summary data
      final summary = _expenseRepository.getExpenseSummary(
        filterPeriod: filterPeriod,
        baseCurrency: 'USD',
      );

      // Get paginated expenses
      final paginatedExpenses = _expenseRepository.getPaginatedExpenses(
        page: 1,
        limit: _pageSize,
        filterPeriod: filterPeriod,
        category: event.category,
      );

      emit(ExpenseLoaded(
        summary: summary,
        paginatedExpenses: paginatedExpenses,
        currentFilter: filterPeriod,
        currentCategory: event.category,
      ));
    } catch (e) {
      emit(ExpenseError(
        message: 'Failed to load expenses',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpenseLoaded || !currentState.paginatedExpenses.hasMore) {
      return;
    }

    try {
      final newState = currentState.copyWith(isLoadingMore: true);
      emit(newState);

      final nextPage = currentState.paginatedExpenses.currentPage + 1;
      final newPaginatedExpenses = _expenseRepository.getPaginatedExpenses(
        page: nextPage,
        limit: _pageSize,
        filterPeriod: currentState.currentFilter,
        category: currentState.currentCategory,
      );

      // Combine existing expenses with new ones
      final combinedExpenses = [
        ...currentState.paginatedExpenses.expenses,
        ...newPaginatedExpenses.expenses,
      ];

      final updatedPaginatedExpenses = newPaginatedExpenses.copyWith(
        expenses: combinedExpenses,
      );

      emit(currentState.copyWith(
        paginatedExpenses: updatedPaginatedExpenses,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseActionLoading('adding'));

      // Convert amount to USD if necessary
      double amountInUsd = event.expense.amount;

      if (event.expense.currency != 'USD') {
        amountInUsd = await _currencyService.convertCurrency(
          fromCurrency: event.expense.currency,
          toCurrency: 'USD',
          amount: event.expense.amount,
        );
      }

      final expenseWithUsd = event.expense.copyWith(amountInUsd: amountInUsd);
      
      await _expenseRepository.addExpense(expenseWithUsd);

      emit(const ExpenseActionSuccess(
        action: 'adding',
        message: 'Expense added successfully',
      ));

      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseActionError(
        action: 'adding',
        message: 'Failed to add expense',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseActionLoading('updating'));

      // Convert amount to USD if necessary
      double amountInUsd = event.expense.amount;

      if (event.expense.currency != 'USD') {
        amountInUsd = await _currencyService.convertCurrency(
          fromCurrency: event.expense.currency,
          toCurrency: 'USD',
          amount: event.expense.amount,
        );
      }

      final expenseWithUsd = event.expense.copyWith(
        amountInUsd: amountInUsd,
        updatedAt: DateTime.now(),
      );

      await _expenseRepository.updateExpense(expenseWithUsd);

      emit(const ExpenseActionSuccess(
        action: 'updating',
        message: 'Expense updated successfully',
      ));

      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseActionError(
        action: 'updating',
        message: 'Failed to update expense',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseActionLoading('deleting'));

      await _expenseRepository.deleteExpense(event.expenseId);

      emit(const ExpenseActionSuccess(
        action: 'deleting',
        message: 'Expense deleted successfully',
      ));

      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseActionError(
        action: 'deleting',
        message: 'Failed to delete expense',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSearchExpenses(
    SearchExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpenseLoaded) return;

    try {
      if (event.query.isEmpty) {
        // Reset to normal view
        add(LoadExpenses(filterPeriod: currentState.currentFilter));
        return;
      }

      final searchResults = _expenseRepository.searchExpenses(event.query);
      
      final paginatedResults = PaginatedExpenses(
        expenses: searchResults.take(_pageSize).toList(),
        currentPage: 1,
        totalPages: (searchResults.length / _pageSize).ceil(),
        totalCount: searchResults.length,
        hasMore: searchResults.length > _pageSize,
      );

      emit(currentState.copyWith(
        paginatedExpenses: paginatedResults,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ExpenseError(
        message: 'Failed to search expenses',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onFilterExpenses(
    FilterExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      // Save filter preference
      await _userRepository.saveFilterPeriod(event.filterPeriod);

      // Load expenses with new filter
      add(LoadExpenses(
        filterPeriod: event.filterPeriod,
        category: event.category,
      ));
    } catch (e) {
      emit(ExpenseError(
        message: 'Failed to filter expenses',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpenseLoaded) {
      add(LoadExpenses(
        filterPeriod: currentState.currentFilter,
        category: currentState.currentCategory,
      ));
    } else {
      add(const LoadExpenses());
    }
  }
}
