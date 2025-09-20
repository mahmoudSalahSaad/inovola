import 'package:flutter_test/flutter_test.dart';
import 'package:inovola/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('should create expense with all required fields', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 'test_id',
        title: 'Test Expense',
        amount: 100.0,
        currency: 'USD',
        amountInUsd: 100.0,
        category: ExpenseCategory.groceries,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.id, 'test_id');
      expect(expense.title, 'Test Expense');
      expect(expense.amount, 100.0);
      expect(expense.currency, 'USD');
      expect(expense.amountInUsd, 100.0);
      expect(expense.category, ExpenseCategory.groceries);
      expect(expense.date, now);
      expect(expense.receiptPath, null);
    });

    test('should create expense with receipt path', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 'test_id',
        title: 'Test Expense',
        amount: 100.0,
        currency: 'USD',
        amountInUsd: 100.0,
        category: ExpenseCategory.groceries,
        date: now,
        receiptPath: '/path/to/receipt.jpg',
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.receiptPath, '/path/to/receipt.jpg');
    });

    test('should copy expense with updated fields', () {
      final now = DateTime.now();
      final originalExpense = Expense(
        id: 'test_id',
        title: 'Original Title',
        amount: 100.0,
        currency: 'USD',
        amountInUsd: 100.0,
        category: ExpenseCategory.groceries,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final updatedExpense = originalExpense.copyWith(
        title: 'Updated Title',
        amount: 150.0,
      );

      expect(updatedExpense.id, 'test_id');
      expect(updatedExpense.title, 'Updated Title');
      expect(updatedExpense.amount, 150.0);
      expect(updatedExpense.currency, 'USD');
      expect(updatedExpense.category, ExpenseCategory.groceries);
    });

    test('should have correct equality', () {
      final now = DateTime.now();
      final expense1 = Expense(
        id: 'test_id',
        title: 'Test Expense',
        amount: 100.0,
        currency: 'USD',
        amountInUsd: 100.0,
        category: ExpenseCategory.groceries,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final expense2 = Expense(
        id: 'test_id',
        title: 'Test Expense',
        amount: 100.0,
        currency: 'USD',
        amountInUsd: 100.0,
        category: ExpenseCategory.groceries,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense1, equals(expense2));
    });
  });

  group('ExpenseCategory Tests', () {
    test('should have correct display names', () {
      expect(ExpenseCategory.groceries.displayName, 'Groceries');
      expect(ExpenseCategory.entertainment.displayName, 'Entertainment');
      expect(ExpenseCategory.transport.displayName, 'Transport');
      expect(ExpenseCategory.rent.displayName, 'Rent');
      expect(ExpenseCategory.shopping.displayName, 'Shopping');
      expect(ExpenseCategory.newsAndPaper.displayName, 'News Paper');
      expect(ExpenseCategory.other.displayName, 'Add Category');
    });

    test('should have correct icon paths', () {
      expect(ExpenseCategory.groceries.iconPath, 'assets/icons/groceries.png');
      expect(ExpenseCategory.entertainment.iconPath, 'assets/icons/entertainment.png');
      expect(ExpenseCategory.transport.iconPath, 'assets/icons/transport.png');
      expect(ExpenseCategory.rent.iconPath, 'assets/icons/rent.png');
      expect(ExpenseCategory.shopping.iconPath, 'assets/icons/shopping.png');
      expect(ExpenseCategory.newsAndPaper.iconPath, 'assets/icons/news_paper.png');
      expect(ExpenseCategory.other.iconPath, 'assets/icons/add_category.png');
    });
  });
}
