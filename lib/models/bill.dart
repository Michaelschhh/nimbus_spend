import 'package:uuid/uuid.dart';

class Bill {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String frequency; // Monthly, Weekly, Yearly, Once
  final String category;
  final bool isPaid;
  final DateTime? paidDate;
  final bool autoPay;
  final String defaultRouting;

  Bill({
    String? id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    required this.category,
    this.isPaid = false,
    this.paidDate,
    this.autoPay = false,
    this.defaultRouting = 'allowance',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'frequency': frequency,
      'category': category,
      'isPaid': isPaid ? 1 : 0,
      'paidDate': paidDate?.toIso8601String(),
      'autoPay': autoPay ? 1 : 0,
      'defaultRouting': defaultRouting,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['dueDate']),
      frequency: map['frequency'],
      category: map['category'],
      isPaid: map['isPaid'] == 1,
      paidDate: map['paidDate'] != null
          ? DateTime.parse(map['paidDate'])
          : null,
      autoPay: map['autoPay'] == 1,
      defaultRouting: map['defaultRouting'] ?? 'allowance',
    );
  }
}
