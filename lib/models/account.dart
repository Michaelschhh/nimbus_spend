import 'package:uuid/uuid.dart';

class Account {
  final String id;
  final String name;
  final double balance;
  final String icon;

  Account({
    String? id,
    required this.name,
    this.balance = 0.0,
    required this.icon,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon': icon,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: (map['balance'] as num).toDouble(),
      icon: map['icon'],
    );
  }

  Account copyWith({
    String? name,
    double? balance,
    String? icon,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
    );
  }
}
