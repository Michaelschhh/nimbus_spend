import 'package:uuid/uuid.dart';

class Saving {
  final String id;
  final String description;
  final double amount;
  final double annualInterestRate;
  final DateTime date;
  final DateTime endDate;
  final bool isCompleted;

  Saving({
    String? id,
    required this.description,
    required this.amount,
    required this.annualInterestRate,
    required this.date,
    required this.endDate,
    this.isCompleted = false,
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
    );
  }
}