import 'package:equatable/equatable.dart';
import '../../models/expense.dart';
import '../../models/expense_summary.dart';
import '../../models/user.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final ExpenseSummary summary;
  final PaginatedExpenses paginatedExpenses;
  final FilterPeriod currentFilter;
  final ExpenseCategory? currentCategory;
  final bool isLoadingMore;
  final String? searchQuery;

  const ExpenseLoaded({
    required this.summary,
    required this.paginatedExpenses,
    required this.currentFilter,
    this.currentCategory,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  ExpenseLoaded copyWith({
    ExpenseSummary? summary,
    PaginatedExpenses? paginatedExpenses,
    FilterPeriod? currentFilter,
    ExpenseCategory? currentCategory,
    bool? isLoadingMore,
    String? searchQuery,
    bool clearCategory = false,
    bool clearSearchQuery = false,
  }) {
    return ExpenseLoaded(
      summary: summary ?? this.summary,
      paginatedExpenses: paginatedExpenses ?? this.paginatedExpenses,
      currentFilter: currentFilter ?? this.currentFilter,
      currentCategory: clearCategory ? null : (currentCategory ?? this.currentCategory),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        paginatedExpenses,
        currentFilter,
        currentCategory,
        isLoadingMore,
        searchQuery,
      ];
}

class ExpenseError extends ExpenseState {
  final String message;
  final String? details;

  const ExpenseError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

class ExpenseActionLoading extends ExpenseState {
  final String action; // 'adding', 'updating', 'deleting'

  const ExpenseActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}

class ExpenseActionSuccess extends ExpenseState {
  final String action;
  final String message;

  const ExpenseActionSuccess({
    required this.action,
    required this.message,
  });

  @override
  List<Object?> get props => [action, message];
}

class ExpenseActionError extends ExpenseState {
  final String action;
  final String message;
  final String? details;

  const ExpenseActionError({
    required this.action,
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [action, message, details];
}
