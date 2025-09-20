import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../blocs/expense/expense_bloc.dart';
import '../blocs/expense/expense_event.dart';
import '../blocs/expense/expense_state.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/expense_summary.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_utils.dart';
import '../utils/animation_utils.dart';
import '../services/export_service.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/expense_list_item.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadData();
    _setupScrollListener();
  }

  void _initializeUser() {
    // Check if user exists, if not create a default user
    final userState = context.read<UserBloc>().state;
    if (userState is UserInitial || userState is UserUnauthenticated) {
      context.read<UserBloc>().add(const CreateDefaultUser());
    }
  }

  void _loadData() {
    context.read<ExpenseBloc>().add(const LoadExpenses());
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<ExpenseBloc>().state;
        if (state is ExpenseLoaded && 
            state.paginatedExpenses.hasMore && 
            !state.isLoadingMore) {
          context.read<ExpenseBloc>().add(const LoadMoreExpenses());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToAddExpense() {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        page: const AddExpenseScreen(),
        type: PageTransitionType.slideUp,
      ),
    ).then((_) {
      // Refresh data when returning from add expense screen
      _loadData();
    });
  }

  void _showExportOptions(ExpenseSummary summary, List<Expense> expenses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExportBottomSheet(summary, expenses),
    );
  }

  Future<void> _handleExport(ExportType type, ExpenseSummary summary, List<Expense> expenses) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      File exportedFile;
      String successMessage = '';

      switch (type) {
        case ExportType.csvExpenses:
          exportedFile = await ExportService.exportToCSV(
            expenses: expenses,
            baseCurrency: summary.baseCurrency,
          );
          successMessage = 'Expenses exported to CSV successfully!';
          break;
        case ExportType.pdfReport:
          exportedFile = await ExportService.exportToPDF(
            expenses: expenses,
            summary: summary,
          );
          successMessage = 'Report exported to PDF successfully!';
          break;
        case ExportType.csvCategories:
          exportedFile = await ExportService.exportCategoryBreakdownToCSV(
            summary: summary,
          );
          successMessage = 'Category breakdown exported successfully!';
          break;
      }

      // Hide loading indicator
      Navigator.of(context).pop();

      if (exportedFile.existsSync()) {
        // Share the file
        await ExportService.shareFile(file: exportedFile);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'Share Again',
              onPressed: () => ExportService.shareFile(file: exportedFile),
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            if (userState is! UserAuthenticated) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = userState.user;

            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                if (expenseState is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (expenseState is ExpenseError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          expenseState.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (expenseState is! ExpenseLoaded) {
                  return const SizedBox.shrink();
                }

                final summary = expenseState.summary;
                final expenses = expenseState.paginatedExpenses.expenses;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ExpenseBloc>().add(const RefreshExpenses());
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            // Background stacked container
                            
                            
                            // Main header container
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                    
                                    Colors.blue.shade700,
                                                    AppTheme.darkBlue,
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  ResponsiveUtils.getHorizontalPadding(context),
                                  ResponsiveUtils.getVerticalPadding(context),
                                  ResponsiveUtils.getHorizontalPadding(context),
                                  ResponsiveUtils.getVerticalPadding(context) + 8,
                                ),
                                child: Column(
                                  children: [
                                    _buildHeader(user),
                                    SizedBox(height: ResponsiveUtils.getSpacing(context) + 160),
                       
                                  ],
                                ),
                              ),
                            ),
                                         Padding(
                                           padding: const EdgeInsets.only(top: 100 ,left: 16,right: 16),
                                           child: AnimationUtils.slideIn(
                                             child: AnimationUtils.scaleIn(
                                               child: BalanceSummaryCard(summary: summary),
                                               delay: 0.2,
                                             ),
                                             begin: const Offset(0.0, 0.3),
                                             delay: 0.1,
                                           ),
                                         ),
                          ],
                        ),
                      ),

                      // Filter and Recent Expenses
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            ResponsiveUtils.getHorizontalPadding(context),
                            ResponsiveUtils.getVerticalPadding(context),
                            ResponsiveUtils.getHorizontalPadding(context),
                            ResponsiveUtils.getVerticalPadding(context) - 4,
                          ),
                          child: Column(
                            children: [
                              _buildFilterSection(expenseState),
                              SizedBox(height: ResponsiveUtils.getSpacing(context)),
                              _buildRecentExpensesHeader(expenses.length),
                            ],
                          ),
                        ),
                      ),

                      // Expenses List
                      expenses.isEmpty
                          ? SliverToBoxAdapter(
                              child: _buildEmptyState(),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index < expenses.length) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      delay: const Duration(milliseconds: 100),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveUtils.getHorizontalPadding(context),
                                              vertical: 4.0,
                                            ),
                                            child: ExpenseListItem(
                                              expense: expenses[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (expenseState.isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                childCount: expenses.length + 
                                    (expenseState.isLoadingMore ? 1 : 0),
                              ),
                            ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUtils.getAvatarRadius(context),
          backgroundColor: Colors.white.withOpacity(0.2),
          child: user.profileImagePath != null
              ? ClipOval(
                  child: Image.asset(
                    user.profileImagePath!,
                    width: ResponsiveUtils.getAvatarRadius(context) * 2,
                    height: ResponsiveUtils.getAvatarRadius(context) * 2,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getIconSize(context) - 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Export functionality hidden for now
        // IconButton(
        //   onPressed: () {
        //     final expenseState = context.read<ExpenseBloc>().state;
        //     if (expenseState is ExpenseLoaded) {
        //       _showExportOptions(expenseState.summary, expenseState.paginatedExpenses.expenses);
        //     }
        //   },
        //   icon: const Icon(
        //     Icons.download_rounded,
        //     color: Colors.white,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFilterSection(ExpenseLoaded state) {
    return Row(
      children: [
        Expanded(
          child: FilterDropdown(
            currentFilter: state.currentFilter,
            onFilterChanged: (filter) {
              context.read<ExpenseBloc>().add(
                FilterExpenses(filterPeriod: filter),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () {
            // Handle "see all"
          },
          child: Text(
            'see all',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpensesHeader(int count) {
    return Row(
      children: [
        Text(
          'Recent Expenses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          '$count items',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddExpense,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportBottomSheet(ExpenseSummary summary, List<Expense> expenses) {
    final exportOptions = ExportService.getExportOptions();
    
    return AnimationUtils.slideIn(
      begin: const Offset(0.0, 1.0),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
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
                    'Export Options',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
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
            
            // Export options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: exportOptions.map((option) {
                  return AnimationUtils.staggeredListItem(
                    index: exportOptions.indexOf(option),
                    child: _buildExportOptionTile(option, summary, expenses),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionTile(ExportOption option, ExpenseSummary summary, List<Expense> expenses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            _handleExport(option.type, summary, expenses);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerColor.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getExportIcon(option.type),
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getExportIcon(ExportType type) {
    switch (type) {
      case ExportType.csvExpenses:
        return Icons.table_chart_rounded;
      case ExportType.pdfReport:
        return Icons.picture_as_pdf_rounded;
      case ExportType.csvCategories:
        return Icons.pie_chart_rounded;
    }
  }
}
