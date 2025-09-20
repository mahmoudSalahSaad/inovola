import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/widgets/balance_summary_card.dart';
import '../../lib/models/expense_summary.dart';
import '../../lib/models/user.dart';

void main() {
  group('BalanceSummaryCard Widget Tests', () {
    late ExpenseSummary testSummary;

    setUp(() {
      testSummary = ExpenseSummary(
        totalIncome: 1000.0,
        totalExpenses: 250.0,
        totalBalance: 750.0,
        recentExpenses: [],
        filterPeriod: FilterPeriod.thisMonth,
        expensesByCategory: {},
        baseCurrency: 'USD',
      );
    });

    Widget createTestWidget(ExpenseSummary summary) {
      return MaterialApp(
        home: Scaffold(
          body: BalanceSummaryCard(summary: summary),
        ),
      );
    }

    group('Display Tests', () {
      testWidgets('should display total balance correctly', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(find.text('Total Balance'), findsOneWidget);
        expect(find.text('\$750.00'), findsOneWidget);
      });

      testWidgets('should display income and expenses', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(find.text('Income'), findsOneWidget);
        expect(find.text('Expenses'), findsOneWidget);
        expect(find.text('\$1,000.00'), findsOneWidget);
        expect(find.text('\$250.00'), findsOneWidget);
      });

      testWidgets('should display EXPENSER brand text', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(find.text('EXPENSER'), findsOneWidget);
      });

      testWidgets('should display currency badge', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(find.text('USD'), findsOneWidget);
      });

      testWidgets('should handle different currencies', (tester) async {
        // Arrange
        final eurSummary = testSummary.copyWith(baseCurrency: 'EUR');

        // Act
        await tester.pumpWidget(createTestWidget(eurSummary));

        // Assert
        expect(find.text('EUR'), findsOneWidget);
        expect(find.text('€750.00'), findsOneWidget);
      });

      testWidgets('should handle zero values', (tester) async {
        // Arrange
        final zeroSummary = ExpenseSummary(
          totalIncome: 0.0,
          totalExpenses: 0.0,
          totalBalance: 0.0,
          recentExpenses: [],
          filterPeriod: FilterPeriod.thisMonth,
          expensesByCategory: {},
          baseCurrency: 'USD',
        );

        // Act
        await tester.pumpWidget(createTestWidget(zeroSummary));

        // Assert
        expect(find.text('\$0.00'), findsNWidgets(3)); // Balance, income, expenses
      });

      testWidgets('should handle negative balance', (tester) async {
        // Arrange
        final negativeSummary = testSummary.copyWith(
          totalIncome: 100.0,
          totalExpenses: 200.0,
          totalBalance: -100.0,
        );

        // Act
        await tester.pumpWidget(createTestWidget(negativeSummary));

        // Assert
        expect(find.text('-\$100.00'), findsOneWidget);
      });
    });

    group('Visual Structure Tests', () {
      testWidgets('should have proper card structure', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(find.byType(BalanceSummaryCard), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should display income and expense indicators', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        // Check for colored circle indicators
        final containers = tester.widgetList<Container>(find.byType(Container));
        expect(containers.length, greaterThan(0));
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with small screen
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestWidget(testSummary));
        expect(find.byType(BalanceSummaryCard), findsOneWidget);

        // Test with large screen
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(createTestWidget(testSummary));
        expect(find.byType(BalanceSummaryCard), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(testSummary));

        // Assert
        expect(tester.getSemantics(find.byType(BalanceSummaryCard)), isNotNull);
      });
    });
  });
}
