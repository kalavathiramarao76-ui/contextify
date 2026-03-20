import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/analysis.dart';

/// Service that calls the Contextify backend API to analyze text.
/// The API key is kept server-side — no secrets in the client.
class AiService {
  static const String _baseUrl =
      'https://contextify-backend.vercel.app/api/analyze';

  /// Analyze the given [text] with the specified [type] using the backend API.
  /// Falls back to local keyword-based analysis when the API is unavailable.
  Future<AnalysisResult> analyzeText(String text, AnalysisType type) async {
    try {
      return await _callBackendApi(text, type);
    } catch (_) {
      return _fallbackLocalAnalysis(text, type);
    }
  }

  Future<AnalysisResult> _callBackendApi(
      String text, AnalysisType type) async {
    final body = jsonEncode({
      'text': text,
      'type': type.jsonValue,
    });

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Backend API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AnalysisResult.fromJson(data);
  }

  /// Basic keyword-based fallback when the API is unavailable.
  AnalysisResult _fallbackLocalAnalysis(String text, AnalysisType type) {
    final lower = text.toLowerCase();
    final flags = <RedFlag>[];
    var manipulationScore = 0;

    const manipulationPatterns = {
      'you always': (
        'Absolute statement — often used to generalize',
        FlagType.manipulation
      ),
      'you never': (
        'Absolute statement — often used to generalize',
        FlagType.manipulation
      ),
      'if you really loved': (
        'Guilt-tripping / emotional blackmail',
        FlagType.manipulation
      ),
      'after everything i': ('Guilt-tripping tactic', FlagType.manipulation),
      'you made me': ('Blame shifting', FlagType.gaslighting),
      'you\'re overreacting': (
        'Dismissing feelings — possible gaslighting',
        FlagType.gaslighting
      ),
      'that never happened': (
        'Reality denial — gaslighting indicator',
        FlagType.gaslighting
      ),
      'everyone agrees': (
        'Appeal to majority — pressure tactic',
        FlagType.pressureTactic
      ),
      'limited time': ('Urgency / pressure tactic', FlagType.pressureTactic),
      'act now': ('Urgency / pressure tactic', FlagType.pressureTactic),
      'don\'t tell anyone': (
        'Secrecy request — manipulation red flag',
        FlagType.manipulation
      ),
      'you owe me': ('Guilt-based obligation', FlagType.manipulation),
    };

    const legalPatterns = {
      'non-refundable': (
        'May lock you into payment',
        FlagType.hiddenCost
      ),
      'auto-renew': (
        'Automatic charge without explicit consent',
        FlagType.hiddenCost
      ),
      'waive your right': (
        'You may be giving up legal protections',
        FlagType.legalRisk
      ),
      'binding arbitration': (
        'Limits your legal options',
        FlagType.legalRisk
      ),
      'subject to change': (
        'Terms may change without notice',
        FlagType.misleading
      ),
      'additional fees': ('Hidden costs may apply', FlagType.hiddenCost),
      'not responsible for': ('Liability disclaimer', FlagType.legalRisk),
    };

    void checkPatterns(Map<String, (String, FlagType)> patterns,
        RiskLevel severity, int scoreAdd) {
      for (final entry in patterns.entries) {
        if (lower.contains(entry.key)) {
          final (reason, flagType) = entry.value;
          flags.add(RedFlag(
            text: entry.key,
            reason: reason,
            severity: severity,
            type: flagType,
          ));
          manipulationScore += scoreAdd;
        }
      }
    }

    checkPatterns(manipulationPatterns, RiskLevel.warning, 12);
    checkPatterns(legalPatterns, RiskLevel.caution, 8);

    manipulationScore = manipulationScore.clamp(0, 100);

    final riskLevel = switch (manipulationScore) {
      >= 60 => RiskLevel.danger,
      >= 35 => RiskLevel.warning,
      >= 15 => RiskLevel.caution,
      _ => RiskLevel.safe,
    };

    final tone = manipulationScore > 40
        ? 'potentially manipulative'
        : manipulationScore > 15
            ? 'slightly concerning'
            : 'neutral';

    return AnalysisResult(
      summary: flags.isEmpty
          ? 'This text appears straightforward with no obvious red flags. '
              '(Analyzed offline — results may be limited.)'
          : 'This text contains ${flags.length} potential concern(s). '
              'Review the flagged items below. '
              '(Analyzed offline — results may be limited.)',
      riskLevel: riskLevel,
      manipulationScore: manipulationScore,
      flags: flags,
      keyPoints: [
        'Word count: ${text.split(RegExp(r'\s+')).length}',
        if (flags.isEmpty) 'No red flags detected in offline analysis',
        if (flags.isNotEmpty)
          '${flags.length} flag(s) detected via keyword matching',
        'Full AI analysis unavailable — connect to the internet for deeper insights',
      ],
      hiddenMeanings: const [],
      suggestedResponse: null,
      toneAnalysis: tone,
      category: type.jsonValue,
    );
  }
}
