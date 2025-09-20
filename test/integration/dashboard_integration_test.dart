import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inovola/widgets/filter_dropdown.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/screens/dashboard_screen.dart';
import '../../lib/blocs/user/user_bloc.dart';
import '../../lib/blocs/user/user_state.dart';
import '../../lib/blocs/user/user_event.dart';
import '../../lib/blocs/expense/expense_bloc.dart';
import '../../lib/blocs/expense/expense_state.dart';
import '../../lib/blocs/expense/expense_event.dart';
import '../../lib/models/user.dart';
import '../../lib/models/expense.dart';
import '../../lib/models/expense_summary.dart';

// Generate mocks
@GenerateMocks([UserBloc, ExpenseBloc])
import '../screens/dashboard_screen_test.mocks.dart';

void main() {
  group('Dashboard Integration Tests', () {
    late MockUserBloc mockUserBloc;
    late MockExpenseBloc mockExpenseBloc;
    late User testUser;
    late ExpenseSummary testSummary;
    late List<Expense> testExpenses;

    setUp(() {
      mockUserBloc = MockUserBloc();
      mockExpenseBloc = MockExpenseBloc();

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
      ];

      testSummary = ExpenseSummary(
        totalIncome: 1000.0,
        totalExpenses: 50.0,
        totalBalance: 950.0,
        recentExpenses: testExpenses,
        filterPeriod: FilterPeriod.thisMonth,
        expensesByCategory: {ExpenseCategory.groceries: 50.0},
        baseCurrency: 'USD',
      );
    });

    Widget createTestApp() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>.value(value: mockUserBloc),
            BlocProvider<ExpenseBloc>.value(value: mockExpenseBloc),
          ],
          child: const DashboardScreen(),
        ),
      );
    }

    group('User Authentication Flow', () {
      testWidgets('should handle user authentication state changes', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(const UserInitial());
        when(mockUserBloc.stream).thenAnswer((_) => Stream.fromIterable([
          const UserInitial(),
          UserAuthenticated(testUser),
        ]));
        
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump(); // Initial state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(); // After authentication
        
        // Assert
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Good Morning'), findsOneWidget);
      });

      testWidgets('should dispatch CreateDefaultUser for unauthenticated users', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(const UserUnauthenticated());
        when(mockExpenseBloc.state).thenReturn(const ExpenseLoading());

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Assert
        verify(mockUserBloc.add(const CreateDefaultUser())).called(1);
      });
    });

    group('Expense Loading Flow', () {
      testWidgets('should handle expense loading states correctly', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserAuthenticated(testUser)));
        
        when(mockExpenseBloc.state).thenReturn(const ExpenseLoading());
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.fromIterable([
          const ExpenseLoading(),
          ExpenseLoaded(
            summary: testSummary,
            paginatedExpenses: PaginatedExpenses(
              expenses: testExpenses,
              hasMore: false,
              currentPage: 1,
              totalPages: 1, totalCount: 100,
            ),
            currentFilter: FilterPeriod.thisMonth,
            isLoadingMore: false,
          ),
        ]));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump(); // Loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(); // Loaded state
        
        // Assert
        expect(find.text('Recent Expenses'), findsOneWidget);
        expect(find.text('1 items'), findsOneWidget);
      });

      testWidgets('should handle expense error states', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserAuthenticated(testUser)));
        
        when(mockExpenseBloc.state).thenReturn(const ExpenseError('Network error', message: 'N/A'));
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(const ExpenseError('Network error', message: 'N/A')));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Network error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should dispatch LoadExpenses on initialization', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(const ExpenseLoading());

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Assert
        verify(mockExpenseBloc.add(const LoadExpenses())).called(1);
      });
    });

    group('Filter Integration', () {
      testWidgets('should handle filter changes through bloc', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Tap on filter dropdown
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // Tap on a different filter option
        await tester.tap(find.text('Last 7 days'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockExpenseBloc.add(const FilterExpenses(filterPeriod: FilterPeriod.lastSevenDays))).called(1);
      });
    });

    group('Refresh Integration', () {
      testWidgets('should handle pull-to-refresh correctly', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,    
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Perform pull-to-refresh
        await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert
        verify(mockExpenseBloc.add(const RefreshExpenses())).called(1);
      });
    });

    group('Pagination Integration', () {
      testWidgets('should handle load more expenses when scrolling', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: true,
            currentPage: 1,
            totalPages: 3,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Scroll to bottom
        final scrollView = find.byType(CustomScrollView);
        await tester.fling(scrollView, const Offset(0, -1000), 1000);
        await tester.pumpAndSettle();

        // Assert
        verify(mockExpenseBloc.add(const LoadMoreExpenses())).called(greaterThan(0));
      });

      testWidgets('should show loading indicator when loading more', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: true,
            currentPage: 1,
            totalPages: 3,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: true,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Navigation Integration', () {
      testWidgets('should navigate to add expense and refresh on return', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Tap FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Navigate back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Assert
        // Should call LoadExpenses again after returning
        verify(mockExpenseBloc.add(const LoadExpenses())).called(greaterThan(0));
      });
    });

    group('Error Recovery Integration', () {
      testWidgets('should retry loading data when retry button is pressed', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(const ExpenseError( 'Network error', message: 'N/A'));
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.value(const ExpenseError( 'Network error', message: 'N/A')));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Assert
        verify(mockExpenseBloc.add(const LoadExpenses())).called(greaterThan(0));
      });
    });

    group('State Persistence Integration', () {
      testWidgets('should maintain scroll position during state updates', (tester) async {
        // Arrange
        final manyExpenses = List.generate(20, (index) => Expense(
          id: 'expense-$index',
          title: 'Expense $index',
          amount: 10.0 + index,
          currency: 'USD',
          amountInUsd: 10.0 + index,
          category: ExpenseCategory.groceries,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary.copyWith(recentExpenses: manyExpenses),
          paginatedExpenses: PaginatedExpenses(
            expenses: manyExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        ));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Scroll down
        await tester.fling(find.byType(CustomScrollView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Trigger a state update
        when(mockExpenseBloc.state).thenReturn(ExpenseLoaded(
          summary: testSummary.copyWith(recentExpenses: manyExpenses),
          paginatedExpenses: PaginatedExpenses(
            expenses: manyExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.lastSevenDays, // Changed filter
          isLoadingMore: false,
        ));

        await tester.pump();

        // Assert
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    group('Real-time Updates Integration', () {
      testWidgets('should handle real-time expense updates', (tester) async {
        // Arrange
        when(mockUserBloc.state).thenReturn(UserAuthenticated(testUser));
        
        final initialState = ExpenseLoaded(
          summary: testSummary,
          paginatedExpenses: PaginatedExpenses(
            expenses: testExpenses,
            hasMore: false,
            currentPage: 1,
            totalPages: 1,
            totalCount: 100,
          ),
          currentFilter: FilterPeriod.thisMonth,
          isLoadingMore: false,
        );

        when(mockExpenseBloc.state).thenReturn(initialState);
        when(mockExpenseBloc.stream).thenAnswer((_) => Stream.fromIterable([
          initialState,
          ExpenseLoaded(
            summary: testSummary.copyWith(totalExpenses: 100.0, totalBalance: 900.0),
            paginatedExpenses: PaginatedExpenses(
              expenses: [...testExpenses, Expense(
                id: 'expense-2',
                title: 'New Expense',
                amount: 50.0,
                currency: 'USD',
                amountInUsd: 50.0,
                category: ExpenseCategory.transport,
                date: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )],
              hasMore: false,
              currentPage: 1,
              totalPages: 1,
              totalCount: 100,
                  ),
            currentFilter: FilterPeriod.thisMonth,
            isLoadingMore: false,
          ),
        ]));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump(); // Initial state
        
        expect(find.text('1 items'), findsOneWidget);
        
        await tester.pump(); // Updated state

        // Assert
        expect(find.text('2 items'), findsOneWidget);
      });
    });
  });
}
