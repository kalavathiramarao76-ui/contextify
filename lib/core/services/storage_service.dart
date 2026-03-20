import 'package:hive_flutter/hive_flutter.dart';

import '../models/analysis.dart';

/// Hive-based local storage for analyses.
class StorageService {
  static const String _boxName = 'analyses';
  late Box<String> _box;

  /// Initialize Hive and open the analyses box.
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Persist an [Analysis] to local storage.
  Future<void> saveAnalysis(Analysis analysis) async {
    await _box.put(analysis.id, analysis.toJsonString());
  }

  /// Retrieve all stored analyses, sorted newest first.
  List<Analysis> getAnalyses() {
    final analyses = _box.values
        .map((json) => Analysis.fromJsonString(json))
        .toList();
    analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analyses;
  }

  /// Delete an analysis by [id].
  Future<void> deleteAnalysis(String id) async {
    await _box.delete(id);
  }

  /// Toggle the favorite state of an analysis by [id].
  Future<Analysis?> toggleFavorite(String id) async {
    final json = _box.get(id);
    if (json == null) return null;

    final analysis = Analysis.fromJsonString(json);
    final updated = analysis.copyWith(isFavorite: !analysis.isFavorite);
    await _box.put(id, updated.toJsonString());
    return updated;
  }

  /// Return the total number of stored analyses.
  int getAnalysisCount() => _box.length;

  /// Delete all stored analyses.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
