class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}
