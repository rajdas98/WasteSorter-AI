class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.category,
    required this.binColor,
    required this.timestamp,
    this.imageUrl,
  });

  final String id;
  final String category;
  final String binColor;
  final DateTime timestamp;
  final String? imageUrl;

  factory ScanRecord.fromJson(String id, Map<String, dynamic> json) {
    return ScanRecord(
      id: id,
      category: json['category']?.toString() ?? 'Unknown',
      binColor: json['binColor']?.toString() ?? 'Unknown',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category,
      'binColor': binColor,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
