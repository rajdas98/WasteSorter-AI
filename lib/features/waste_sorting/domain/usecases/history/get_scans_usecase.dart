import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/repositories/history/history_repository.dart';

class GetScansUseCase {
  GetScansUseCase(this._repository);

  final HistoryRepository _repository;

  Future<List<ScanHistoryItem>> call() {
    return _repository.getScans();
  }
}
