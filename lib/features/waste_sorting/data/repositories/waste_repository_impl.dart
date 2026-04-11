import 'package:wastesorter/features/waste_sorting/data/services/ai_service.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/waste_result.dart';
import 'package:wastesorter/features/waste_sorting/domain/repositories/waste_repository.dart';

class WasteRepositoryImpl implements WasteRepository {
  WasteRepositoryImpl(this._aiService);

  final AIService _aiService;

  @override
  Future<WasteResult> analyzeImage(String base64Image) async {
    final Map<String, dynamic> json = await _aiService.analyzeWasteImage(
      base64Image,
    );

    final String category = (json['category'] ?? 'Unknown').toString();
    final String bin = (json['bin_color'] ?? json['bin'] ?? 'Blue').toString();
    final String explanation =
        (json['message'] ?? json['explanation'] ?? 'No details provided.')
            .toString();

    return WasteResult(
      category: category,
      binColor: bin,
      explanation: explanation,
    );
  }
}
