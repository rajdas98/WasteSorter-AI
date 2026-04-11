class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.totalPoints,
    required this.level,
  });

  final String uid;
  final String displayName;
  final int totalPoints;
  final String level;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Eco Hero',
      totalPoints: int.tryParse(json['totalPoints']?.toString() ?? '') ?? 0,
      level: json['level']?.toString() ?? 'Novice',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'totalPoints': totalPoints,
      'level': level,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    int? totalPoints,
    String? level,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
    );
  }
}
