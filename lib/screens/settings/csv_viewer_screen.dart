import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'package:share_plus/share_plus.dart';

class CsvViewerScreen extends StatefulWidget {
  final String filePath;

  const CsvViewerScreen({super.key, required this.filePath});

  @override
  State<CsvViewerScreen> createState() => _CsvViewerScreenState();
}

class _CsvViewerScreenState extends State<CsvViewerScreen> {
  List<List<String>> _csvData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _error = 'CSV file not found.';
          _isLoading = false;
        });
        return;
      }

      final text = await file.readAsString();
      final lines = text.split('\n');
      
      final data = <List<String>>[];
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        
        // Basic CSV parsing handling quoted values
        List<String> row = [];
        bool inQuotes = false;
        StringBuffer buffer = StringBuffer();
        
        for (int i = 0; i < line.length; i++) {
          final char = line[i];
          if (char == '"') {
            if (i + 1 < line.length && line[i + 1] == '"') {
              buffer.write('"'); // Escaped double quote
              i++;
            } else {
              inQuotes = !inQuotes;
            }
          } else if (char == ',' && !inQuotes) {
            row.add(buffer.toString());
            buffer.clear();
          } else {
            buffer.write(char);
          }
        }
        row.add(buffer.toString());
        data.add(row);
      }

      setState(() {
        _csvData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to read CSV: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles([XFile(widget.filePath)], subject: 'Nimbus Spend Data Export'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
              : _csvData.isEmpty
                  ? const Center(child: Text('No data found in CSV.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
                          columns: _csvData.first.map((header) {
                            return DataColumn(
                              label: Text(
                                header,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          rows: _csvData.skip(1).map((row) {
                            return DataRow(
                              cells: row.map((cell) {
                                return DataCell(Text(cell));
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
    );
  }
}
