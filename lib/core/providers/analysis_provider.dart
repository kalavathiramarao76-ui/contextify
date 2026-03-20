import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analysis.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

/// State for the analysis notifier.
class AnalysisState {
  const AnalysisState({
    this.analyses = const [],
    this.isLoading = false,
    this.error,
    this.currentResult,
  });

  final List<Analysis> analyses;
  final bool isLoading;
  final String? error;
  final Analysis? currentResult;

  AnalysisState copyWith({
    List<Analysis>? analyses,
    bool? isLoading,
    String? error,
    Analysis? currentResult,
    bool clearError = false,
    bool clearCurrentResult = false,
  }) {
    return AnalysisState(
      analyses: analyses ?? this.analyses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentResult:
          clearCurrentResult ? null : (currentResult ?? this.currentResult),
    );
  }
}

// ── Providers ──

final storageServiceProvider = Provider<StorageService>((ref) {
  final service = StorageService();
  // init() is called in main.dart before runApp, so the box is already open
  return service;
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Manages the list of analyses and drives AI analysis.
class AnalysisNotifier extends Notifier<AnalysisState> {
  late final StorageService _storage;
  late final AiService _ai;

  @override
  AnalysisState build() {
    _storage = ref.watch(storageServiceProvider);
    _ai = ref.watch(aiServiceProvider);
    return const AnalysisState();
  }

  /// Load history from local storage.
  void loadHistory() {
    final analyses = _storage.getAnalyses();
    state = state.copyWith(analyses: analyses, clearError: true);
  }

  /// Run AI analysis on [text] with given [type], save to storage, and update state.
  Future<Analysis> analyze(String text, AnalysisType type) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearCurrentResult: true,
    );

    try {
      final result = await _ai.analyzeText(text, type);
      final analysis = Analysis(
        inputText: text,
        inputType: type,
        result: result,
      );

      await _storage.saveAnalysis(analysis);

      state = state.copyWith(
        isLoading: false,
        currentResult: analysis,
        analyses: [analysis, ...state.analyses],
      );

      return analysis;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete an analysis by [id].
  Future<void> delete(String id) async {
    await _storage.deleteAnalysis(id);
    state = state.copyWith(
      analyses: state.analyses.where((a) => a.id != id).toList(),
    );
  }

  /// Toggle the favorite status of an analysis.
  Future<void> toggleFavorite(String id) async {
    final updated = await _storage.toggleFavorite(id);
    if (updated == null) return;

    state = state.copyWith(
      analyses: state.analyses.map((a) => a.id == id ? updated : a).toList(),
    );
  }

  /// Clear current result.
  void clearResult() {
    state = state.copyWith(clearCurrentResult: true);
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    await _storage.clearAll();
    state = state.copyWith(analyses: []);
  }
}

/// The main analysis provider.
final analysisProvider =
    NotifierProvider<AnalysisNotifier, AnalysisState>(AnalysisNotifier.new);

/// Computed provider: analyses sorted by date (newest first).
final analysisHistoryProvider = Provider<List<Analysis>>((ref) {
  final analyses = ref.watch(analysisProvider).analyses;
  final sorted = List<Analysis>.from(analyses);
  sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted;
});
