import 'package:uuid/uuid.dart';

class Saving {
  final String id;
  final String description;
  final double amount;
  final double annualInterestRate;
  final DateTime date;
  final DateTime endDate;
  final bool isCompleted;
  final String fundingSource;
  final bool isMatured;

  Saving({
    String? id,
    required this.description,
    required this.amount,
    required this.annualInterestRate,
    required this.date,
    required this.endDate,
    this.isCompleted = false,
    this.fundingSource = 'allowance',
    this.isMatured = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'annualInterestRate': annualInterestRate,
      'date': date.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'fundingSource': fundingSource,
      'isMatured': isMatured ? 1 : 0,
    };
  }

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      annualInterestRate: map['annualInterestRate'],
      date: DateTime.parse(map['date']),
      endDate: DateTime.parse(map['endDate']),
      isCompleted: map['isCompleted'] == 1,
      fundingSource: map['fundingSource'] ?? 'allowance',
      isMatured: map['isMatured'] == 1,
    );
  }
  
  Saving copyWith({
    String? description,
    double? amount,
    double? annualInterestRate,
    DateTime? date,
    DateTime? endDate,
    bool? isCompleted,
    String? fundingSource,
    bool? isMatured,
  }) {
    return Saving(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      fundingSource: fundingSource ?? this.fundingSource,
      isMatured: isMatured ?? this.isMatured,
    );
  }
}