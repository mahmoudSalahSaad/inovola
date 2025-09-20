import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/responsive_utils.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getCardPadding(context) - 4),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: ResponsiveUtils.getIconSize(context) * 2,
                  height: ResponsiveUtils.getIconSize(context) * 2,
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getCategoryColor(),
                    size: ResponsiveUtils.getIconSize(context),
                  ),
                ),
                
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                
                // Expense Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense.category.displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '- ${CurrencyFormatter.formatAmount(expense.amount, currency: expense.currency)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense.title.isNotEmpty 
                                  ? expense.title 
                                  : expense.category.displayName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            DateFormatter.formatTime(expense.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (expense.category) {
      case ExpenseCategory.groceries:
        return const Color(0xFF10B981); // Green
      case ExpenseCategory.entertainment:
        return const Color(0xFF8B5CF6); // Purple
      case ExpenseCategory.transport:
        return const Color(0xFF06B6D4); // Cyan
      case ExpenseCategory.rent:
        return const Color(0xFFF59E0B); // Amber
      case ExpenseCategory.shopping:
        return const Color(0xFFEC4899); // Pink
      case ExpenseCategory.newsAndPaper:
        return const Color(0xFF6366F1); // Indigo
      case ExpenseCategory.other:
        return AppTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon() {
    switch (expense.category) {
      case ExpenseCategory.groceries:
        return Icons.shopping_cart_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.rent:
        return Icons.home_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.newsAndPaper:
        return Icons.newspaper_outlined;
      case ExpenseCategory.other:
        return Icons.category_outlined;
    }
  }
}
