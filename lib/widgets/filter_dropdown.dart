import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../utils/bottom_sheet_utils.dart';
import '../utils/responsive_utils.dart';

class FilterDropdown extends StatelessWidget {
  final FilterPeriod currentFilter;
  final Function(FilterPeriod) onFilterChanged;

  const FilterDropdown({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  void _showFilterBottomSheet(BuildContext context) {
    BottomSheetUtils.showElegantBottomSheet(
      context: context,
      title: 'Filter by Period',
      height: MediaQuery.of(context).size.height * 0.5,
      content: _buildFilterOptions(context),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        BottomSheetUtils.buildSectionHeader(
          context: context,
          title: 'Time Period',
          subtitle: 'Choose a time period to filter your expenses',
        ),
        ...FilterPeriod.values.map((period) {
          return BottomSheetUtils.buildOptionTile(
            context: context,
            title: period.displayName,
            subtitle: _getFilterDescription(period),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentFilter == period 
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFilterIcon(period),
                color: currentFilter == period 
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            isSelected: currentFilter == period,
            onTap: () {
              onFilterChanged(period);
              Navigator.of(context).pop();
            },
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getFilterDescription(FilterPeriod period) {
    switch (period) {
      case FilterPeriod.thisMonth:
        return 'Show expenses from this month';
      case FilterPeriod.lastSevenDays:
        return 'Show expenses from last 7 days';
      case FilterPeriod.lastThirtyDays:
        return 'Show expenses from last 30 days';
      case FilterPeriod.thisYear:
        return 'Show expenses from this year';
      case FilterPeriod.all:
        return 'Show all expenses';
    }
  }

  IconData _getFilterIcon(FilterPeriod period) {
    switch (period) {
      case FilterPeriod.thisMonth:
        return Icons.calendar_month;
      case FilterPeriod.lastSevenDays:
        return Icons.view_week;
      case FilterPeriod.lastThirtyDays:
        return Icons.date_range;
      case FilterPeriod.thisYear:
        return Icons.calendar_today;
      case FilterPeriod.all:
        return Icons.all_inclusive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFilterBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getCardPadding(context),
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFilterIcon(currentFilter),
                  color: AppTheme.primaryBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentFilter.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to change',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
