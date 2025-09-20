import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/expense_summary.dart';
import '../models/user.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

/// Service for exporting expense data to various formats
class ExportService {
  /// Export expenses to CSV format
  static Future<File> exportToCSV({
    required List<Expense> expenses,
    required String baseCurrency,
    String? customFileName,
  }) async {
    try {
      // Create CSV data
      List<List<dynamic>> csvData = [
        // Header row
        [
          'Date',
          'Title',
          'Category',
          'Amount',
          'Currency',
          'Amount (USD)',
          'Receipt',
          'Created At',
        ],
      ];

      // Add expense data
      for (final expense in expenses) {
        csvData.add([
          DateFormatter.formatDate(expense.date),
          expense.title.isEmpty ? expense.category.displayName : expense.title,
          expense.category.displayName,
          expense.amount.toStringAsFixed(2),
          expense.currency,
          expense.amountInUsd.toStringAsFixed(2),
          expense.receiptPath != null ? 'Yes' : 'No',
          DateFormatter.formatDateTime(expense.createdAt),
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? 
          'expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV data to file
      await file.writeAsString(csvString);

      return file;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export expenses to PDF format
  static Future<File> exportToPDF({
    required List<Expense> expenses,
    required ExpenseSummary summary,
    String? customFileName,
  }) async {
    try {
      final pdf = pw.Document();

      // Use default font for PDF generation
      final ttf = pw.Font.helvetica();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              _buildPDFHeader(summary, ttf),
              pw.SizedBox(height: 20),
              
              // Summary section
              _buildPDFSummary(summary, ttf),
              pw.SizedBox(height: 30),
              
              // Expenses table
              _buildPDFExpensesTable(expenses, ttf),
              
              // Footer
              pw.SizedBox(height: 30),
              _buildPDFFooter(ttf),
            ];
          },
        ),
      );

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? 
          'expenses_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Write PDF data to file
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Export expenses by category to CSV
  static Future<File> exportCategoryBreakdownToCSV({
    required ExpenseSummary summary,
    String? customFileName,
  }) async {
    try {
      List<List<dynamic>> csvData = [
        // Header row
        ['Category', 'Amount', 'Percentage', 'Currency'],
      ];

      final totalExpenses = summary.totalExpenses;
      
      // Add category data
      for (final entry in summary.expensesByCategory.entries) {
        final percentage = totalExpenses > 0 
            ? (entry.value / totalExpenses * 100).toStringAsFixed(1)
            : '0.0';
        
        csvData.add([
          entry.key.displayName,
          entry.value.toStringAsFixed(2),
          '$percentage%',
          summary.baseCurrency,
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? 
          'category_breakdown_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV data to file
      await file.writeAsString(csvString);

      return file;
    } catch (e) {
      throw Exception('Failed to export category breakdown: $e');
    }
  }

  /// Share exported file
  static Future<void> shareFile({
    required File file,
    String? subject,
    String? text,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? 'Expense Report',
        text: text ?? 'Here is your expense report from Expenser app.',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// Get export options for user selection
  static List<ExportOption> getExportOptions() {
    return [
      ExportOption(
        type: ExportType.csvExpenses,
        title: 'Export Expenses (CSV)',
        description: 'Export all expenses in CSV format',
        icon: 'assets/icons/csv.png',
      ),
      ExportOption(
        type: ExportType.pdfReport,
        title: 'Export Report (PDF)',
        description: 'Export detailed report in PDF format',
        icon: 'assets/icons/pdf.png',
      ),
      ExportOption(
        type: ExportType.csvCategories,
        title: 'Category Breakdown (CSV)',
        description: 'Export expenses grouped by category',
        icon: 'assets/icons/chart.png',
      ),
    ];
  }

  // Private helper methods for PDF generation

  static pw.Widget _buildPDFHeader(ExpenseSummary summary, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'EXPENSER',
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.Text(
              'Expense Report',
              style: pw.TextStyle(
                font: font,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.blue700, thickness: 2),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generated on ${DateFormatter.formatDateTime(DateTime.now())}',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Text(
          'Period: ${_getFilterPeriodDescription(summary.filterPeriod)}',
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildPDFSummary(ExpenseSummary summary, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Income', summary.totalIncome, summary.baseCurrency, font, PdfColors.green),
              _buildSummaryItem('Total Expenses', summary.totalExpenses, summary.baseCurrency, font, PdfColors.red),
              _buildSummaryItem('Balance', summary.totalBalance, summary.baseCurrency, font, PdfColors.blue),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, double amount, String currency, pw.Font font, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          CurrencyFormatter.formatAmount(amount, currency: currency),
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPDFExpensesTable(List<Expense> expenses, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Expense Details (${expenses.length} items)',
          style: pw.TextStyle(
            font: font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Date', font, isHeader: true),
                _buildTableCell('Description', font, isHeader: true),
                _buildTableCell('Category', font, isHeader: true),
                _buildTableCell('Amount', font, isHeader: true),
                _buildTableCell('Currency', font, isHeader: true),
              ],
            ),
            // Data rows
            ...expenses.map((expense) => pw.TableRow(
              children: [
                _buildTableCell(DateFormatter.formatDate(expense.date), font),
                _buildTableCell(
                  expense.title.isEmpty ? expense.category.displayName : expense.title,
                  font,
                ),
                _buildTableCell(expense.category.displayName, font),
                _buildTableCell(expense.amount.toStringAsFixed(2), font),
                _buildTableCell(expense.currency, font),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildPDFFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by Expenser App - Your Personal Finance Tracker',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey500,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static String _getFilterPeriodDescription(FilterPeriod period) {
    switch (period) {
      case FilterPeriod.thisMonth:
        return 'This Month';
      case FilterPeriod.lastSevenDays:
        return 'Last 7 Days';
      case FilterPeriod.lastThirtyDays:
        return 'Last 30 Days';
      case FilterPeriod.thisYear:
        return 'This Year';
      case FilterPeriod.all:
        return 'All Time';
    }
  }
}

/// Export option model
class ExportOption {
  final ExportType type;
  final String title;
  final String description;
  final String icon;

  const ExportOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Export type enumeration
enum ExportType {
  csvExpenses,
  pdfReport,
  csvCategories,
}
