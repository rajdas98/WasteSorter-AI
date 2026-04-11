import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/repositories/history/history_repository.dart';

class SaveScanUseCase {
  SaveScanUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call(ScanHistoryItem item) {
    return _repository.saveScan(item);
  }
}
