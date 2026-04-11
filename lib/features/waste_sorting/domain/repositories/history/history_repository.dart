import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';

abstract class HistoryRepository {
  Future<void> saveScan(ScanHistoryItem item);
  Future<List<ScanHistoryItem>> getScans();
}
