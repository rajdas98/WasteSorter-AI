import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/repositories/history/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;
  static const String _key = 'scan_history_v1';

  @override
  Future<List<ScanHistoryItem>> getScans() async {
    final String? raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <ScanHistoryItem>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveScan(ScanHistoryItem item) async {
    final List<ScanHistoryItem> current = await getScans();
    final List<ScanHistoryItem> updated = <ScanHistoryItem>[item, ...current];
    final String encoded =
        jsonEncode(updated.map((ScanHistoryItem e) => e.toJson()).toList());
    await _preferences.setString(_key, encoded);
  }
}
