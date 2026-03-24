import 'package:uuid/uuid.dart';

class Income {
  final String id;
  final double amount;
  final DateTime date;
  final String source;
  final String note;

  Income({
    String? id,
    required this.amount,
    required this.date,
    required this.source,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'source': source,
      'note': note,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      source: map['source'],
      note: map['note'] ?? '',
    );
  }
}
