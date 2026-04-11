import '../entities/waste_result.dart';

abstract class WasteRepository {
  Future<WasteResult> analyzeImage(String base64Image);
}
