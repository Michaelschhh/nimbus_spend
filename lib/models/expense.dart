import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final bool isRecurring;
  final String? recurringFrequency; // Daily, Weekly, Monthly, Yearly
  final double lifeCostHours;
  final String fundingSource;
  final String? linkedId;
  final String? receiptImagePath;
  final String? voiceMemoPath;

  Expense({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    this.isRecurring = false,
    this.recurringFrequency,
    required this.lifeCostHours,
    this.fundingSource = 'allowance',
    this.linkedId,
    this.receiptImagePath,
    this.voiceMemoPath,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
      'lifeCostHours': lifeCostHours,
      'fundingSource': fundingSource,
      'linkedId': linkedId,
      'receiptImagePath': receiptImagePath,
      'voiceMemoPath': voiceMemoPath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      isRecurring: map['isRecurring'] == 1,
      recurringFrequency: map['recurringFrequency'],
      lifeCostHours: (map['lifeCostHours'] as num).toDouble(),
      fundingSource: map['fundingSource'] ?? 'allowance',
      linkedId: map['linkedId'],
      receiptImagePath: map['receiptImagePath'],
      voiceMemoPath: map['voiceMemoPath'],
    );
  }
}
