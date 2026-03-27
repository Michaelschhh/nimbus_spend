import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import 'sound_service.dart';
import '../screens/settings/csv_viewer_screen.dart';

class ExportService {
  static Future<void> exportExpensesToCsv(BuildContext context, List<Expense> expenses, SettingsProvider sProv) async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export.')),
      );
      return;
    }
    
    try {
      final StringBuffer csv = StringBuffer();
      // Write Header
      csv.writeln('Date,Category,Note,Funding Source,Amount (${sProv.settings.currency}),Life Cost (Hours)');
      
      // Sort oldest to newest or newest to oldest. Let's do newest first.
      final sorted = List<Expense>.from(expenses)..sort((a, b) => b.date.compareTo(a.date));
      
      for (final e in sorted) {
        final date = Formatters.date(e.date);
        // Escape quotes by doubling them, wrap in quotes
        final category = '"${e.category.replaceAll('"', '""')}"';
        final note = '"${e.note.replaceAll('"', '""')}"';
        final amount = e.amount.toStringAsFixed(2);
        final hours = e.lifeCostHours.toStringAsFixed(1);
        final source = '"${e.fundingSource}"';
        
        csv.writeln('$date,$category,$note,$source,$amount,$hours');
      }
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/Nimbus_Ledger_$timestamp.csv';
      final file = File(path);
      
      await file.writeAsString(csv.toString());
      SoundService.success();
      
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Export Successful 🎉'),
          content: const Text('Your ledger has been successfully compiled. What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(path)], subject: 'Nimbus Spend Data Export');
              },
              child: const Text('Share Externally'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CsvViewerScreen(filePath: path)),
                );
              },
              child: const Text('View in App'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    }
  }
}
