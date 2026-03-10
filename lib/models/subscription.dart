import 'package:uuid/uuid.dart';

class Subscription {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime startDate;
  final String frequency;
  final DateTime nextDueDate;
  final bool isActive;
  final String note;

  Subscription({
    String? id,
    required this.name,
    required this.amount,
    required this.category,
    required this.startDate,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  // This method allows the RecurringService to "bump" the date
  Subscription copyWith({DateTime? nextDueDate, bool? isActive}) {
    return Subscription(
      id: id,
      name: name,
      amount: amount,
      category: category,
      startDate: startDate,
      frequency: frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      note: note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'frequency': frequency,
      'nextDueDate': nextDueDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'note': note,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      startDate: DateTime.parse(map['startDate']),
      frequency: map['frequency'],
      nextDueDate: DateTime.parse(map['nextDueDate']),
      isActive: map['isActive'] == 1,
      note: map['note'] ?? '',
    );
  }
}
