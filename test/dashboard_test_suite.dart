import 'package:flutter_test/flutter_test.dart';

// Import all dashboard-related tests
import 'screens/dashboard_screen_test.dart' as dashboard_screen_tests;
import 'widgets/balance_summary_card_test.dart' as balance_card_tests;
import 'widgets/filter_dropdown_test.dart' as filter_dropdown_tests;
import 'widgets/expense_list_item_test.dart' as expense_item_tests;
import 'integration/dashboard_integration_test.dart' as integration_tests;

/// Comprehensive test suite for the Dashboard Screen and all its components
/// 
/// This test suite covers:
/// - Dashboard Screen widget tests
/// - Balance Summary Card widget tests
/// - Filter Dropdown widget tests
/// - Expense List Item widget tests
/// - Integration tests for bloc interactions
/// - Error handling and edge cases
/// - Responsive design tests
/// - Accessibility tests
/// 
/// Run this test suite with: flutter test test/dashboard_test_suite.dart
void main() {
  group('🏠 Dashboard Test Suite - Complete Coverage', () {
    group('📱 Dashboard Screen Tests', () {
      dashboard_screen_tests.main();
    });

    group('💳 Balance Summary Card Tests', () {
      balance_card_tests.main();
    });

    group('🔽 Filter Dropdown Tests', () {
      filter_dropdown_tests.main();
    });

    group('📋 Expense List Item Tests', () {
      expense_item_tests.main();
    });

    group('🔄 Integration Tests', () {
      integration_tests.main();
    });
  });
}

/// Test Coverage Summary:
/// 
/// ✅ Dashboard Screen Widget Tests (35+ tests):
/// - Initial state handling (loading, error, success)
/// - User authentication flow
/// - Expense loading states
/// - Empty state display
/// - Navigation interactions
/// - Pull-to-refresh functionality
/// - Scroll behavior and pagination
/// - Bloc event dispatching
/// - Theme and styling
/// - Responsive design
/// 
/// ✅ Balance Summary Card Tests (15+ tests):
/// - Balance display formatting
/// - Income and expense display
/// - Currency handling (USD, EUR, etc.)
/// - Zero and negative values
/// - Visual structure and styling
/// - Responsive design
/// - Accessibility
/// 
/// ✅ Filter Dropdown Tests (20+ tests):
/// - Filter period display
/// - Bottom sheet interactions
/// - Filter selection callbacks
/// - Icon display for each period
/// - Visual structure
/// - Accessibility
/// - Responsive design
/// 
/// ✅ Expense List Item Tests (25+ tests):
/// - Expense data display
/// - Category icons and names
/// - Currency formatting
/// - Date formatting
/// - Different expense categories
/// - Edge cases (long titles, zero amounts)
/// - Visual structure
/// - Accessibility
/// - Responsive design
/// 
/// ✅ Integration Tests (15+ tests):
/// - User authentication flow
/// - Expense loading and error handling
/// - Filter integration with bloc
/// - Pull-to-refresh integration
/// - Pagination integration
/// - Navigation flow
/// - Error recovery
/// - State persistence
/// - Real-time updates
/// 
/// Total Test Coverage: 110+ comprehensive tests
/// 
/// Test Categories Covered:
/// - ✅ Widget rendering and display
/// - ✅ User interactions and gestures
/// - ✅ State management and bloc integration
/// - ✅ Navigation and routing
/// - ✅ Error handling and recovery
/// - ✅ Edge cases and boundary conditions
/// - ✅ Responsive design and screen sizes
/// - ✅ Accessibility and semantics
/// - ✅ Data formatting and display
/// - ✅ Real-time updates and state changes
