import 'package:equatable/equatable.dart';
import '../../models/expense.dart';
import '../../models/user.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final FilterPeriod? filterPeriod;
  final ExpenseCategory? category;

  const LoadExpenses({this.filterPeriod, this.category});

  @override
  List<Object?> get props => [filterPeriod, category];
}

class LoadMoreExpenses extends ExpenseEvent {
  const LoadMoreExpenses();
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class SearchExpenses extends ExpenseEvent {
  final String query;

  const SearchExpenses(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterExpenses extends ExpenseEvent {
  final FilterPeriod filterPeriod;
  final ExpenseCategory? category;

  const FilterExpenses({
    required this.filterPeriod,
    this.category,
  });

  @override
  List<Object?> get props => [filterPeriod, category];
}

class RefreshExpenses extends ExpenseEvent {
  const RefreshExpenses();
}
