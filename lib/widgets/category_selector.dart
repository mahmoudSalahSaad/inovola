import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_utils.dart';

class CategorySelector extends StatelessWidget {
  final ExpenseCategory selectedCategory;
  final Function(ExpenseCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseCategory.values;
    final spacing = ResponsiveUtils.getSpacing(context);
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing + 4),
          
          // Categories Grid
          _buildCategoriesGrid(context, categories, spacing),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<ExpenseCategory> categories, double spacing) {
    // Create a more balanced grid layout
    return Column(
      children: [
        // First row (4 categories)
        Row(
          children: categories.take(4).map((category) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: _buildCategoryItem(context, category),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: spacing),
        // Second row (3 categories + empty space)
        Row(
          children: [
            ...categories.skip(4).take(3).map((category) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: _buildCategoryItem(context, category),
                ),
              );
            }),
            const Expanded(child: SizedBox()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, ExpenseCategory category) {
    final isSelected = category == selectedCategory;
    final categoryColor = _getCategoryColor(category);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          // Fixed dimensions for consistent card sizes
          height: ResponsiveUtils.isSmallScreen(context) ? 85 : 95,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: ResponsiveUtils.getCardPadding(context) - 6,
          ),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor,
                      categoryColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : AppTheme.backgroundGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? categoryColor.withOpacity(0.3)
                  : AppTheme.dividerColor.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: categoryColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: categoryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with fixed size
              Container(
                width: ResponsiveUtils.isSmallScreen(context) ? 32 : 36,
                height: ResponsiveUtils.isSmallScreen(context) ? 32 : 36,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.25)
                      : categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected 
                      ? Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: isSelected 
                      ? Colors.white
                      : categoryColor,
                  size: ResponsiveUtils.isSmallScreen(context) ? 16 : 18,
                ),
              ),
              const SizedBox(height: 6),
              // Category name with smaller, consistent text
              Flexible(
                child: Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? Colors.white
                        : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: ResponsiveUtils.isSmallScreen(context) ? 9 : 10,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Selection indicator with fixed positioning
              SizedBox(
                height: 8,
                child: isSelected 
                    ? Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return const Color(0xFF16A085); // Emerald Green
      case ExpenseCategory.entertainment:
        return const Color(0xFF9B59B6); // Amethyst Purple
      case ExpenseCategory.transport:
        return const Color(0xFF3498DB); // Bright Blue
      case ExpenseCategory.rent:
        return const Color(0xFFE67E22); // Carrot Orange
      case ExpenseCategory.shopping:
        return const Color(0xFFE91E63); // Pink
      case ExpenseCategory.newsAndPaper:
        return const Color(0xFF673AB7); // Deep Purple
      case ExpenseCategory.other:
        return const Color(0xFF34495E); // Wet Asphalt
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return Icons.local_grocery_store_rounded;
      case ExpenseCategory.entertainment:
        return Icons.theaters_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_filled_rounded;
      case ExpenseCategory.rent:
        return Icons.home_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.newsAndPaper:
        return Icons.article_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }
}
