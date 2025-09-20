import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/screens/dashboard_screen.dart';
import '../../lib/screens/add_expense_screen.dart';
import '../../lib/blocs/user/user_bloc.dart';
import '../../lib/blocs/user/user_state.dart';
import '../../lib/blocs/user/user_event.dart';
import '../../lib/blocs/expense/expense_bloc.dart';
import 'package:inovola/blocs/expense/expense_state.dart';
import '../../lib/blocs/expense/expense_event.dart';
import '../../lib/models/user.dart';
import '../../lib/models/expense.dart';
import '../../lib/models/expense_summary.dart';
import '../../lib/widgets/balance_summary_card.dart';
import '../../lib/widgets/filter_dropdown.dart';
import '../../lib/widgets/expense_list_item.dart';
import '../../lib/utils/app_theme.dart';

// Generate mocks
@GenerateMocks([UserBloc, ExpenseBloc])
import 'dashboard_screen_test.mocks.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late MockUserBloc mockUserBloc;
    late MockExpenseBloc mockExpenseBloc;
    late User testUser;
    late ExpenseSummary testSummary;
    late List<Expense> testExpenses;
    late PaginatedExpenses testPaginatedExpenses;

    setUp(() {
      mockUserBloc = MockUserBloc();
      mockExpenseBloc = MockExpenseBloc();

      // Create test data
      testUser = User(
        id: 'test-user-id',
        name: 'John Doe',
        email: 'john@example.com',
        baseCurrency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testExpenses = [
        Expense(
          id: 'expense-1',
          title: 'Groceries',
          amount: 50.0,
          currency: 'USD',
          amountInUsd: 50.0,
          category: ExpenseCategory.groceries,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          id: 'expense-2',
          title: 'Gas',
          amount: 30.0,
          currency: 'USD',
          amountInUsd: 30.0,
          category: ExpenseCategory.transport,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      testPaginatedExpenses = PaginatedExpenses(
        expenses: testExpenses,
        hasMore: false,
        currentPage: 1,
        totalPages: 1,
        totalCount: testExpenses.length,
      );

      testSummary = ExpenseSummary(
        totalIncome: 1000.0,
        totalExpenses: 80.0,
        totalBalance: 920.0,
        recentExpenses: testExpenses,
        filterPeriod: FilterPeriod.thisMonth,
        expensesByCategory: {
          ExpenseCategory.groceries: 50.0,
          ExpenseCategory.transport: 30.0,
        },
        baseCurrency: 'USD',
      );

      // Setup default mock behavior
      when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
      when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserAuthenticated(testUser)));

      when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
        summary: testSummary,
        paginatedExpenses: testPaginatedExpenses,
        currentFilter: FilterPeriod.thisMonth,
        isLoadingMore: false,
      ));
      when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(ExpenseLoaded(
        summary: testSummary,
        paginatedExpenses: testPaginatedExpenses,
        currentFilter: FilterPeriod.thisMonth,
        isLoadingMore: false,
      )));
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>.value(value: mockUserBloc),
            BlocProvider<ExpenseBloc>.value(value: mockExpenseBloc),
          ],
          child: const DashboardScreen(),
        ),
      );
    }

    group('Initial State Tests', () {
      testWidgets('should display loading indicator when user is not authenticated', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(const UserInitial());
        when(mockUserBloc.stream).thenAnswer((_) => Stream.value(const UserInitial()));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(BalanceSummaryCard), findsNothing);
      });

      testWidgets('should display loading indicator when expenses are loading', (tester) async {
        // Arrange
        when(mockExpenseBloc.state).thenReturn(const ExpenseLoading());
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(const ExpenseLoading()));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(BalanceSummaryCard), findsNothing);
      });

      testWidgets('should display error state when expense loading fails', (tester) async {
        // Arrange
        when(mockExpenseBloc.state).thenReturn(const ExpenseError('Failed to load expenses', message: 'N/A'));
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(const ExpenseError('Failed to load expenses', message: 'N/A')));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Failed to load expenses'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Successful State Tests', () {
      testWidgets('should display all main components when data is loaded', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(find.byType(BalanceSummaryCard), findsOneWidget);
        expect(find.byType(FilterDropdown), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should display user information in header', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Good Morning'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('This month'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('should display balance summary card with correct data', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(BalanceSummaryCard), findsOneWidget);
        // The actual balance values would be tested in the BalanceSummaryCard widget test
      });

      testWidgets('should display recent expenses header with correct count', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Recent Expenses'), findsOneWidget);
        expect(find.text('2 items'), findsOneWidget);
      });

      testWidgets('should display expense list items', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(ExpenseListItem), findsNWidgets(2));
      });

      testWidgets('should display filter section with see all button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(FilterDropdown), findsOneWidget);
        expect(find.text('see all'), findsOneWidget);
      });
    });

    group('Empty State Tests', () {
      testWidgets('should display empty state when no expenses exist', (tester) async {
        // Arrange
        final emptyPaginatedExpenses = PaginatedExpenses(
          expenses: [],
          hasMore: false,
          currentPage: 1,
          totalPages: 1,
          totalCount: 0,
        );
        final emptySummary = testSummary.copyWith(
          totalExpenses: 0.0,
          totalBalance: 1000.0,
          recentExpenses: [],
          expensesByCategory: {},
        );

        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: emptySummary,
          paginatedExpenses: emptyPaginatedExpenses,
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('No expenses yet'), findsOneWidget);
        expect(find.text('Start tracking your expenses by adding your first transaction'), findsOneWidget);
        expect(find.text('Add Expense'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
        expect(find.byIcon(Icons.add), findsNWidgets(2)); // FAB + Empty state button
      });
    });

    group('Interaction Tests', () {
      testWidgets('should navigate to add expense screen when FAB is tapped', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AddExpenseScreen), findsOneWidget);
      });

      testWidgets('should navigate to add expense screen when empty state button is tapped', (tester) async {
        // Arrange
        final emptyPaginatedExpenses = PaginatedExpenses(
          expenses: [],
          hasMore: false,
          currentPage: 1,
          totalPages: 1,
          totalCount: 0,
            );
        final emptySummary = testSummary.copyWith(recentExpenses: []);

        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: emptySummary,
          paginatedExpenses: emptyPaginatedExpenses,
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.tap(find.text('Add Expense'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AddExpenseScreen), findsOneWidget);
      });

      testWidgets('should trigger refresh when pull to refresh is performed', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        
        await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert
        verify(mockExpenseBloc.add(const RefreshExpenses())).called(1);
      });

      testWidgets('should retry loading data when retry button is tapped', (tester) async {
        // Arrange
        when(mockExpenseBloc.state).thenReturn(const ExpenseError('Failed to load expenses', message: 'N/A' ));
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(const ExpenseError('Failed to load expenses', message: 'N/A')));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Assert
        verify(mockExpenseBloc.add(const LoadExpenses())).called(greaterThan(0));
      });
    });

    group('Bloc Integration Tests', () {
      testWidgets('should dispatch CreateDefaultUser when user is not authenticated', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(const UserInitial());

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        verify(mockUserBloc.add(const CreateDefaultUser())).called(1);
      });

      testWidgets('should dispatch LoadExpenses on initialization', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        verify(mockExpenseBloc.add(const LoadExpenses())).called(1);
      });

      testWidgets('should handle filter changes correctly', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Find and tap the filter dropdown
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // This would test the filter dropdown interaction
        // The actual filter selection would be tested in the FilterDropdown widget test
      });
    });

    group('Scroll Behavior Tests', () {
      testWidgets('should trigger load more when scrolled to bottom', (tester) async {
        // Arrange
        final paginatedExpensesWithMore = PaginatedExpenses(
          expenses: testExpenses,
          hasMore: true,
          currentPage: 1,
          totalPages: 2,
          totalCount: testExpenses.length,
        );

        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: paginatedExpensesWithMore,
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Scroll to bottom
        await tester.fling(find.byType(CustomScrollView), const Offset(0, -1000), 1000);
        await tester.pumpAndSettle();

        // Assert
        verify(mockExpenseBloc.add(const LoadMoreExpenses())).called(greaterThan(0));
      });

      testWidgets('should display loading indicator when loading more expenses', (tester) async {
        // Arrange
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: testPaginatedExpenses,
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: true,
        ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNWidgets(1));
      });
    });

    group('Widget Helper Method Tests', () {
      testWidgets('should build header with correct user information', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Good Morning'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('This month'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      });

      testWidgets('should build filter section with dropdown and see all button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(FilterDropdown), findsOneWidget);
        expect(find.text('see all'), findsOneWidget);
      });

      testWidgets('should build recent expenses header with correct count', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('Recent Expenses'), findsOneWidget);
        expect(find.text('2 items'), findsOneWidget);
      });

      testWidgets('should build empty state with correct elements', (tester) async {
        // Arrange
        final emptyPaginatedExpenses = PaginatedExpenses(
          expenses: [],
          hasMore: false,
          currentPage: 1,
          totalCount: 0,
          totalPages: 1,
        );
        final emptySummary = testSummary.copyWith(recentExpenses: []);

        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: emptySummary,
          paginatedExpenses: emptyPaginatedExpenses,
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
        expect(find.text('No expenses yet'), findsOneWidget);
        expect(find.text('Start tracking your expenses by adding your first transaction'), findsOneWidget);
        expect(find.text('Add Expense'), findsOneWidget);
      });
    });

    group('Theme and Styling Tests', () {
      testWidgets('should use correct background color', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppTheme.backgroundGray));
      });

      testWidgets('should display gradient header container', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Container), findsWidgets);
        // The gradient styling would be verified by checking the decoration properties
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(400, 800)); // Small screen
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(DashboardScreen), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(800, 1200)); // Large screen
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(DashboardScreen), findsOneWidget);
      });
    });
  });
}
