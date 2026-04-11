import '../entities/waste_result.dart';
import '../repositories/waste_repository.dart';

class AnalyzeWasteUseCase {
  AnalyzeWasteUseCase(this._repository);

  final WasteRepository _repository;

  Future<WasteResult> call(String base64Image) {
    return _repository.analyzeImage(base64Image);
  }
}
