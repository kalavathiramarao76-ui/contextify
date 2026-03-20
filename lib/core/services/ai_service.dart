import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/analysis.dart';

/// Service that calls the Groq API (llama-3.3-70b-versatile) to analyze text.
class AiService {
  // Set via --dart-define=GROQ_API_KEY=xxx at build time, or pass at runtime
  static const String _groqKey = String.fromEnvironment('GROQ_API_KEY',
      defaultValue: '');
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Analyze the given [text] with the specified [type] using the Groq API.
  /// Falls back to local keyword-based analysis when the API is unavailable.
  Future<AnalysisResult> analyzeText(String text, AnalysisType type) async {
    try {
      return await _callGroqApi(text, type);
    } catch (_) {
      return _fallbackLocalAnalysis(text, type);
    }
  }

  Future<AnalysisResult> _callGroqApi(String text, AnalysisType type) async {
    final systemPrompt = _buildSystemPrompt(type);

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.3,
      'max_tokens': 2048,
      'response_format': {'type': 'json_object'},
    });

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_groqKey',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('No response from Groq API');
    }

    final content =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return AnalysisResult.fromJson(parsed);
  }

  String _buildSystemPrompt(AnalysisType type) {
    return '''You are Contextify, an AI that decodes text into plain English. You analyze ${type.label} content.

Your job:
1. Provide a clear plain-English summary of what the text actually says/means.
2. Detect manipulation tactics: gaslighting, DARVO (Deny, Attack, Reverse Victim & Offender), love bombing, guilt tripping, pressure tactics, emotional blackmail.
3. Flag legal risks, hidden costs, or hidden obligations.
4. Analyze the tone (e.g. passive-aggressive, professional, manipulative, friendly, threatening).
5. Identify hidden meanings or implications.
6. Suggest a response the user could send.

Return ONLY valid JSON with this exact structure:
{
  "summary": "Plain English explanation of what this text means",
  "risk_level": "safe|caution|warning|danger",
  "manipulation_score": 0-100,
  "flags": [
    {
      "text": "exact quote from the text",
      "reason": "why this is flagged",
      "severity": "safe|caution|warning|danger",
      "type": "manipulation|legal_risk|hidden_cost|gaslighting|pressure_tactic|misleading|unclear"
    }
  ],
  "key_points": ["point 1", "point 2"],
  "hidden_meanings": ["meaning 1", "meaning 2"],
  "suggested_response": "A suggested reply the user could send",
  "tone_analysis": "e.g. passive-aggressive, professional, manipulative",
  "category": "${type.jsonValue}"
}

Rules:
- manipulation_score: 0 = no manipulation, 100 = extremely manipulative
- Be thorough but not alarmist — only flag genuinely concerning patterns
- If the text is benign, say so and give a low score
- Always provide at least 2 key_points
- hidden_meanings can be empty if there are none''';
  }

  /// Basic keyword-based fallback when the API is unavailable.
  AnalysisResult _fallbackLocalAnalysis(String text, AnalysisType type) {
    final lower = text.toLowerCase();
    final flags = <RedFlag>[];
    var manipulationScore = 0;

    // -- Manipulation keywords --
    const manipulationPatterns = {
      'you always': ('Absolute statement — often used to generalize', FlagType.manipulation),
      'you never': ('Absolute statement — often used to generalize', FlagType.manipulation),
      'if you really loved': ('Guilt-tripping / emotional blackmail', FlagType.manipulation),
      'after everything i': ('Guilt-tripping tactic', FlagType.manipulation),
      'you made me': ('Blame shifting', FlagType.gaslighting),
      'you\'re overreacting': ('Dismissing feelings — possible gaslighting', FlagType.gaslighting),
      'that never happened': ('Reality denial — gaslighting indicator', FlagType.gaslighting),
      'everyone agrees': ('Appeal to majority — pressure tactic', FlagType.pressureTactic),
      'limited time': ('Urgency / pressure tactic', FlagType.pressureTactic),
      'act now': ('Urgency / pressure tactic', FlagType.pressureTactic),
      'don\'t tell anyone': ('Secrecy request — manipulation red flag', FlagType.manipulation),
      'you owe me': ('Guilt-based obligation', FlagType.manipulation),
    };

    // -- Legal / cost keywords --
    const legalPatterns = {
      'non-refundable': ('May lock you into payment', FlagType.hiddenCost),
      'auto-renew': ('Automatic charge without explicit consent', FlagType.hiddenCost),
      'waive your right': ('You may be giving up legal protections', FlagType.legalRisk),
      'binding arbitration': ('Limits your legal options', FlagType.legalRisk),
      'subject to change': ('Terms may change without notice', FlagType.misleading),
      'additional fees': ('Hidden costs may apply', FlagType.hiddenCost),
      'not responsible for': ('Liability disclaimer', FlagType.legalRisk),
    };

    void checkPatterns(Map<String, (String, FlagType)> patterns, RiskLevel severity, int scoreAdd) {
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
          ? 'This text appears straightforward with no obvious red flags. (Analyzed offline — results may be limited.)'
          : 'This text contains ${flags.length} potential concern(s). Review the flagged items below. (Analyzed offline — results may be limited.)',
      riskLevel: riskLevel,
      manipulationScore: manipulationScore,
      flags: flags,
      keyPoints: [
        'Word count: ${text.split(RegExp(r'\s+')).length}',
        if (flags.isEmpty) 'No red flags detected in offline analysis',
        if (flags.isNotEmpty) '${flags.length} flag(s) detected via keyword matching',
        'Full AI analysis unavailable — connect to the internet for deeper insights',
      ],
      hiddenMeanings: const [],
      suggestedResponse: null,
      toneAnalysis: tone,
      category: type.jsonValue,
    );
  }
}
