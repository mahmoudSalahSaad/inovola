import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/widgets/filter_dropdown.dart';
import '../../lib/models/user.dart';

void main() {
  group('FilterDropdown Widget Tests', () {
    late List<FilterPeriod> capturedFilters;

    setUp(() {
      capturedFilters = [];
    });

    Widget createTestWidget(FilterPeriod currentFilter) {
      return MaterialApp(
        home: Scaffold(
          body: FilterDropdown(
            currentFilter: currentFilter,
            onFilterChanged: (filter) {
              capturedFilters.add(filter);
            },
          ),
        ),
      );
    }

    group('Display Tests', () {
      testWidgets('should display current filter correctly', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));

        // Assert
        expect(find.text('This month'), findsOneWidget);
        expect(find.text('Tap to change'), findsOneWidget);
      });

      testWidgets('should display filter icon', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));

        // Assert
        expect(find.byIcon(Icons.calendar_month), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      });

      testWidgets('should display different filter periods correctly', (tester) async {
        for (final period in FilterPeriod.values) {
          // Act
          await tester.pumpWidget(createTestWidget(period));

          // Assert
          expect(find.text(period.displayName), findsOneWidget);
        }
      });
    });

    group('Interaction Tests', () {
      testWidgets('should open bottom sheet when tapped', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Filter by Period'), findsOneWidget);
        expect(find.text('Time Period'), findsOneWidget);
        expect(find.text('Choose a time period to filter your expenses'), findsOneWidget);
      });

      testWidgets('should display all filter options in bottom sheet', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // Assert
        for (final period in FilterPeriod.values) {
          expect(find.text(period.displayName), findsOneWidget);
        }
      });

      testWidgets('should call onFilterChanged when option is selected', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // Tap on "Last 7 days" option
        await tester.tap(find.text('Last 7 days'));
        await tester.pumpAndSettle();

        // Assert
        expect(capturedFilters, contains(FilterPeriod.lastSevenDays));
      });

      testWidgets('should close bottom sheet after selection', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last 7 days'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Filter by Period'), findsNothing);
      });

      testWidgets('should close bottom sheet when close button is tapped', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Filter by Period'), findsNothing);
      });
    });

    group('Visual Structure Tests', () {
      testWidgets('should have proper card structure', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));

        // Assert
        expect(find.byType(Material), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should display selected state correctly', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        await tester.tap(find.byType(FilterDropdown));
        await tester.pumpAndSettle();

        // Assert - current filter should be visually selected
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Filter Icon Tests', () {
      testWidgets('should display correct icons for each filter period', (tester) async {
        final iconTests = {
          FilterPeriod.thisMonth: Icons.calendar_month,
          FilterPeriod.lastSevenDays: Icons.view_week,
          FilterPeriod.lastThirtyDays: Icons.date_range,
          FilterPeriod.thisYear: Icons.calendar_today,
          FilterPeriod.all: Icons.all_inclusive,
        };

        for (final entry in iconTests.entries) {
          // Act
          await tester.pumpWidget(createTestWidget(entry.key));

          // Assert
          expect(find.byIcon(entry.value), findsOneWidget);
        }
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));

        // Assert
        expect(tester.getSemantics(find.byType(FilterDropdown)), isNotNull);
      });

      testWidgets('should have proper semantics for screen readers', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));

        // Assert
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNotNull);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with small screen
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        expect(find.byType(FilterDropdown), findsOneWidget);

        // Test with large screen
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(createTestWidget(FilterPeriod.thisMonth));
        expect(find.byType(FilterDropdown), findsOneWidget);
      });
    });
  });
}
