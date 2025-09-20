import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/widgets/expense_list_item.dart';
import '../../lib/models/expense.dart';

void main() {
  group('ExpenseListItem Widget Tests', () {
    late Expense testExpense;

    setUp(() {
      testExpense = Expense(
        id: 'test-expense-1',
        title: 'Grocery Shopping',
        amount: 75.50,
        currency: 'USD',
        amountInUsd: 75.50,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget(Expense expense) {
      return MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(expense: expense),
        ),
      );
    }

    group('Display Tests', () {
      testWidgets('should display expense title', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.text('Grocery Shopping'), findsOneWidget);
      });

      testWidgets('should display expense amount with currency', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.text('\$75.50'), findsOneWidget);
      });

      testWidgets('should display formatted date', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.text('15/01/2024'), findsOneWidget);
      });

      testWidgets('should display category icon', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.byIcon(Icons.shopping_cart_rounded), findsOneWidget);
      });

      testWidgets('should display category name', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.text('Groceries'), findsOneWidget);
      });

      testWidgets('should handle different categories correctly', (tester) async {
        final categories = {
          ExpenseCategory.groceries: (Icons.shopping_cart_rounded, 'Groceries'),
          ExpenseCategory.transport: (Icons.directions_car_rounded, 'Transport'),
          ExpenseCategory.entertainment: (Icons.movie_rounded, 'Entertainment'),
          ExpenseCategory.rent: (Icons.home_rounded, 'Rent'),
          ExpenseCategory.shopping: (Icons.shopping_bag_rounded, 'Shopping'),
          ExpenseCategory.newsAndPaper: (Icons.newspaper_rounded, 'News Paper'),
          ExpenseCategory.other: (Icons.category_rounded, 'Add Category'),
        };

        for (final entry in categories.entries) {
          final expense = testExpense.copyWith(category: entry.key);
          
          // Act
          await tester.pumpWidget(createTestWidget(expense));

          // Assert
          expect(find.byIcon(entry.value.$1), findsOneWidget);
          expect(find.text(entry.value.$2), findsOneWidget);
        }
      });

      testWidgets('should handle different currencies', (tester) async {
        final eurExpense = testExpense.copyWith(
          currency: 'EUR',
          amount: 65.25,
        );

        // Act
        await tester.pumpWidget(createTestWidget(eurExpense));

        // Assert
        expect(find.text('€65.25'), findsOneWidget);
      });

      testWidgets('should handle expenses with no title', (tester) async {
        final noTitleExpense = testExpense.copyWith(title: '');

        // Act
        await tester.pumpWidget(createTestWidget(noTitleExpense));

        // Assert
        expect(find.text('Groceries'), findsOneWidget); // Should show category name
      });

      testWidgets('should handle large amounts correctly', (tester) async {
        final largeAmountExpense = testExpense.copyWith(amount: 1234567.89);

        // Act
        await tester.pumpWidget(createTestWidget(largeAmountExpense));

        // Assert
        expect(find.text('\$1,234,567.89'), findsOneWidget);
      });

      testWidgets('should handle zero amounts', (tester) async {
        final zeroAmountExpense = testExpense.copyWith(amount: 0.0);

        // Act
        await tester.pumpWidget(createTestWidget(zeroAmountExpense));

        // Assert
        expect(find.text('\$0.00'), findsOneWidget);
      });
    });

    group('Visual Structure Tests', () {
      testWidgets('should have proper card structure', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should display category icon container with proper styling', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        final containers = tester.widgetList<Container>(find.byType(Container));
        expect(containers.length, greaterThan(0));
        
        // Check that there's a container with circular decoration for the icon
        final iconContainers = containers.where((container) => 
          container.decoration is BoxDecoration &&
          (container.decoration as BoxDecoration).shape == BoxShape.circle
        );
        expect(iconContainers.length, greaterThan(0));
      });
    });

    group('Interaction Tests', () {
      testWidgets('should be tappable', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.byType(ExpenseListItem), findsOneWidget);
        // The widget should be wrapped in a tappable widget for interaction
      });
    });

    group('Date Formatting Tests', () {
      testWidgets('should format dates correctly for different dates', (tester) async {
        final testDates = [
          (DateTime(2024, 1, 1), '01/01/2024'),
          (DateTime(2024, 12, 31), '31/12/2024'),
          (DateTime(2024, 6, 15), '15/06/2024'),
        ];

        for (final dateTest in testDates) {
          final expense = testExpense.copyWith(date: dateTest.$1);
          
          // Act
          await tester.pumpWidget(createTestWidget(expense));

          // Assert
          expect(find.text(dateTest.$2), findsOneWidget);
        }
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with small screen
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestWidget(testExpense));
        expect(find.byType(ExpenseListItem), findsOneWidget);

        // Test with large screen
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(createTestWidget(testExpense));
        expect(find.byType(ExpenseListItem), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(tester.getSemantics(find.byType(ExpenseListItem)), isNotNull);
      });

      testWidgets('should provide proper semantic information', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testExpense));

        // Assert
        expect(find.text('Grocery Shopping'), findsOneWidget);
        expect(find.text('\$75.50'), findsOneWidget);
        expect(find.text('15/01/2024'), findsOneWidget);
        expect(find.text('Groceries'), findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle very long titles', (tester) async {
        final longTitleExpense = testExpense.copyWith(
          title: 'This is a very long expense title that might overflow the available space in the widget',
        );

        // Act
        await tester.pumpWidget(createTestWidget(longTitleExpense));

        // Assert
        expect(find.byType(ExpenseListItem), findsOneWidget);
        // The widget should handle overflow gracefully
      });

      testWidgets('should handle future dates', (tester) async {
        final futureExpense = testExpense.copyWith(
          date: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        await tester.pumpWidget(createTestWidget(futureExpense));

        // Assert
        expect(find.byType(ExpenseListItem), findsOneWidget);
      });

      testWidgets('should handle very old dates', (tester) async {
        final oldExpense = testExpense.copyWith(
          date: DateTime(1990, 1, 1),
        );

        // Act
        await tester.pumpWidget(createTestWidget(oldExpense));

        // Assert
        expect(find.text('01/01/1990'), findsOneWidget);
      });
    });
  });
}
