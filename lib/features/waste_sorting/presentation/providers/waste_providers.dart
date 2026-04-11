import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wastesorter/features/waste_sorting/data/repositories/history/history_repository_impl.dart';
import 'package:wastesorter/features/waste_sorting/data/repositories/waste_repository_impl.dart';
import 'package:wastesorter/features/waste_sorting/data/services/ai_service.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/user_stats.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/waste_result.dart';
import 'package:wastesorter/features/waste_sorting/domain/usecases/history/get_scans_usecase.dart';
import 'package:wastesorter/features/waste_sorting/domain/usecases/history/save_scan_usecase.dart';
import 'package:wastesorter/features/waste_sorting/domain/usecases/analyze_waste_usecase.dart';

final camerasProvider = FutureProvider<List<CameraDescription>>((
  Ref ref,
) async {
  return availableCameras();
});

final dioProvider = Provider<Dio>((Ref ref) => Dio());

final aiServiceProvider = Provider<AIService>((Ref ref) {
  return AIService(ref.read(dioProvider));
});

final wasteRepositoryProvider = Provider<WasteRepositoryImpl>((Ref ref) {
  return WasteRepositoryImpl(ref.read(aiServiceProvider));
});

final analyzeWasteUseCaseProvider = Provider<AnalyzeWasteUseCase>((Ref ref) {
  return AnalyzeWasteUseCase(ref.read(wasteRepositoryProvider));
});

final aiAnalysisProvider =
    FutureProvider.family<WasteResult, String>((Ref ref, String base64Image) {
      return ref.read(analyzeWasteUseCaseProvider)(base64Image);
    });

final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HistoryRepositoryImpl(prefs);
});

final saveScanUseCaseProvider = Provider<SaveScanUseCase>((Ref ref) {
  return SaveScanUseCase(ref.read(historyRepositoryProvider));
});

final getScansUseCaseProvider = Provider<GetScansUseCase>((Ref ref) {
  return GetScansUseCase(ref.read(historyRepositoryProvider));
});

final scanHistoryProvider = FutureProvider<List<ScanHistoryItem>>((Ref ref) {
  return ref.read(getScansUseCaseProvider)();
});

final sortedCountProvider = FutureProvider<int>((Ref ref) async {
  final scans = await ref.read(getScansUseCaseProvider)();
  return scans.length;
});

final userStatsProvider = FutureProvider<UserStats>((Ref ref) async {
  final List<ScanHistoryItem> scans = await ref.read(getScansUseCaseProvider)();
  final int totalItems = scans.length;
  final int totalPoints = scans.fold<int>(
    0,
    (int prev, ScanHistoryItem item) => prev + item.pointsEarned,
  );
  final double wasteKg = totalItems * 0.1;
  final int nextMilestone = totalItems < 20 ? 20 : 50;
  final int currentMilestone = totalItems > nextMilestone
      ? nextMilestone
      : totalItems;
  final String level = totalItems >= 50
      ? 'Eco-Champion'
      : totalItems >= 20
          ? 'Eco-Warrior'
          : 'Novice';

  return UserStats(
    totalPoints: totalPoints,
    totalItems: totalItems,
    wasteKg: wasteKg,
    currentMilestone: currentMilestone,
    nextMilestone: nextMilestone,
    level: level,
  );
});
