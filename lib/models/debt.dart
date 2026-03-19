import 'package:uuid/uuid.dart';

class Debt {
  final String id;
  final String personName;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime? dueDate;
  final bool isOwedToMe;
  final bool isSettled;
  final double remainingAmount;
  final String? defaultRouting; // 'Monthly Budget', 'Available Resources', or null

  Debt({
    String? id,
    required this.personName,
    required this.amount,
    required this.description,
    required this.date,
    this.dueDate,
    required this.isOwedToMe,
    this.isSettled = false,
    double? remainingAmount,
    this.defaultRouting,
  }) : id = id ?? const Uuid().v4(),
       remainingAmount = remainingAmount ?? amount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isOwedToMe': isOwedToMe ? 1 : 0,
      'isSettled': isSettled ? 1 : 0,
      'remainingAmount': remainingAmount,
      'defaultRouting': defaultRouting,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      personName: map['personName'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isOwedToMe: map['isOwedToMe'] == 1,
      isSettled: map['isSettled'] == 1,
      remainingAmount: (map['remainingAmount'] as num).toDouble(),
      defaultRouting: map['defaultRouting'],
    );
  }
}
