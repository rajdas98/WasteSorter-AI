class WasteResult {
  const WasteResult({
    required this.category,
    required this.binColor,
    required this.explanation,
  });

  final String category;
  final String binColor;
  final String explanation;

  bool get isDry => category.toLowerCase() == 'dry';
}
