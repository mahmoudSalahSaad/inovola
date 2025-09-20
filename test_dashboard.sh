#!/bin/bash

# Dashboard Screen Test Suite Runner
# This script runs all dashboard-related tests with detailed output

echo "🏠 Dashboard Screen Test Suite - Comprehensive Coverage"
echo "======================================================"
echo ""

echo "📱 Running Dashboard Screen Widget Tests..."
flutter test test/screens/dashboard_screen_test.dart --reporter=expanded

echo ""
echo "💳 Running Balance Summary Card Tests..."
flutter test test/widgets/balance_summary_card_test.dart --reporter=expanded

echo ""
echo "🔽 Running Filter Dropdown Tests..."
flutter test test/widgets/filter_dropdown_test.dart --reporter=expanded

echo ""
echo "📋 Running Expense List Item Tests..."
flutter test test/widgets/expense_list_item_test.dart --reporter=expanded

echo ""
echo "🔄 Running Integration Tests..."
flutter test test/integration/dashboard_integration_test.dart --reporter=expanded

echo ""
echo "📊 Running Complete Test Suite..."
flutter test test/dashboard_test_suite.dart --reporter=expanded

echo ""
echo "✅ Dashboard Test Suite Complete!"
echo ""
echo "Test Coverage Summary:"
echo "- Dashboard Screen: 35+ tests"
echo "- Balance Card: 15+ tests"
echo "- Filter Dropdown: 20+ tests"
echo "- Expense List Item: 25+ tests"
echo "- Integration Tests: 15+ tests"
echo "- Total: 110+ comprehensive tests"
