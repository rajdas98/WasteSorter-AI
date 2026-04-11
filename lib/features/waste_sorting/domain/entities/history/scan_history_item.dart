class ScanHistoryItem {
  const ScanHistoryItem({
    required this.imagePath,
    required this.imageBase64,
    required this.result,
    required this.timestamp,
    required this.pointsEarned,
  });

  final String imagePath;
  final String imageBase64;
  final String result;
  final DateTime timestamp;
  final int pointsEarned;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'imageBase64': imageBase64,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'pointsEarned': pointsEarned,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      imagePath: json['imagePath']?.toString() ?? '',
      imageBase64: json['imageBase64']?.toString() ?? '',
      result: json['result']?.toString() ?? 'Dry',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      pointsEarned: int.tryParse(json['pointsEarned']?.toString() ?? '') ?? 10,
    );
  }
}
