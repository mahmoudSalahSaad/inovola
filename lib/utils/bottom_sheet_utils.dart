import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'responsive_utils.dart';

class BottomSheetUtils {
  static Future<T?> showElegantBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height ?? MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.getHorizontalPadding(context),
                16,
                ResponsiveUtils.getHorizontalPadding(context),
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: AppTheme.dividerColor,
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
              ),
            ),
            
            // Content
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildOptionTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getHorizontalPadding(context),
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryBlue.withOpacity(0.1) 
                : Colors.transparent,
            border: isSelected 
                ? Border(
                    left: BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected 
                            ? AppTheme.primaryBlue 
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing,
              ],
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.getHorizontalPadding(context),
        16,
        ResponsiveUtils.getHorizontalPadding(context),
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
