import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final double amountInUsd;

  @HiveField(5)
  final ExpenseCategory category;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? receiptPath;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.amountInUsd,
    required this.category,
    required this.date,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    double? amountInUsd,
    ExpenseCategory? category,
    DateTime? date,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountInUsd: amountInUsd ?? this.amountInUsd,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        currency,
        amountInUsd,
        category,
        date,
        receiptPath,
        createdAt,
        updatedAt,
      ];
}

@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0)
  groceries,

  @HiveField(1)
  entertainment,

  @HiveField(2)
  transport,

  @HiveField(3)
  rent,

  @HiveField(4)
  shopping,

  @HiveField(5)
  newsAndPaper,

  @HiveField(6)
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.newsAndPaper:
        return 'News Paper';
      case ExpenseCategory.other:
        return 'Add Category';
    }
  }

  String get iconPath {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'assets/icons/groceries.png';
      case ExpenseCategory.entertainment:
        return 'assets/icons/entertainment.png';
      case ExpenseCategory.transport:
        return 'assets/icons/transport.png';
      case ExpenseCategory.rent:
        return 'assets/icons/rent.png';
      case ExpenseCategory.shopping:
        return 'assets/icons/shopping.png';
      case ExpenseCategory.newsAndPaper:
        return 'assets/icons/news_paper.png';
      case ExpenseCategory.other:
        return 'assets/icons/add_category.png';
    }
  }
}
