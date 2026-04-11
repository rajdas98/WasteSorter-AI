class UserStats {
  const UserStats({
    required this.totalPoints,
    required this.totalItems,
    required this.wasteKg,
    required this.currentMilestone,
    required this.nextMilestone,
    required this.level,
  });

  final int totalPoints;
  final int totalItems;
  final double wasteKg;
  final int currentMilestone;
  final int nextMilestone;
  final String level;
}
