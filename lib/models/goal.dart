import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime? completedDate;

  Goal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.isCompleted = false,
    this.completedDate,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      isCompleted: map['isCompleted'] == 1,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
    );
  }
}
