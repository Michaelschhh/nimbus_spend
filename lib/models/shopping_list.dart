import 'package:uuid/uuid.dart';

class ShoppingList {
  final String id;
  final String title;
  final DateTime date;
  final bool isCompleted;

  ShoppingList({
    String? id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  ShoppingList copyWith({
    String? title,
    DateTime? date,
    bool? isCompleted,
  }) {
    return ShoppingList(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ShoppingItem {
  final String id;
  final String listId;
  final String name;
  final double price;
  final int quantity;
  final bool isChecked;

  ShoppingItem({
    String? id,
    required this.listId,
    required this.name,
    this.price = 0.0,
    this.quantity = 1,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isChecked': isChecked ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      listId: map['listId'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      isChecked: map['isChecked'] == 1,
    );
  }

  ShoppingItem copyWith({
    String? name,
    double? price,
    int? quantity,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id,
      listId: listId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
