import 'dart:convert';

import 'package:uuid/uuid.dart';

/// The type of input text being analyzed.
enum AnalysisType {
  message,
  contract,
  medicalBill,
  email,
  socialMedia,
  general;

  String get label => switch (this) {
        message => 'Message',
        contract => 'Contract',
        medicalBill => 'Medical Bill',
        email => 'Email',
        socialMedia => 'Social Media',
        general => 'General',
      };

  String get jsonValue => switch (this) {
        message => 'message',
        contract => 'contract',
        medicalBill => 'medical_bill',
        email => 'email',
        socialMedia => 'social_media',
        general => 'general',
      };

  static AnalysisType fromJson(String value) => switch (value) {
        'message' => message,
        'contract' => contract,
        'medical_bill' => medicalBill,
        'email' => email,
        'social_media' => socialMedia,
        _ => general,
      };
}

/// Risk severity level.
enum RiskLevel {
  safe,
  caution,
  warning,
  danger;

  String get label => switch (this) {
        safe => 'Safe',
        caution => 'Caution',
        warning => 'Warning',
        danger => 'Danger',
      };

  int get value => switch (this) {
        safe => 0,
        caution => 1,
        warning => 2,
        danger => 3,
      };

  static RiskLevel fromJson(String value) => switch (value.toLowerCase()) {
        'safe' => safe,
        'caution' => caution,
        'warning' => warning,
        'danger' => danger,
        _ => safe,
      };
}

/// Type of red flag detected.
enum FlagType {
  manipulation,
  legalRisk,
  hiddenCost,
  gaslighting,
  pressureTactic,
  misleading,
  unclear;

  String get label => switch (this) {
        manipulation => 'Manipulation',
        legalRisk => 'Legal Risk',
        hiddenCost => 'Hidden Cost',
        gaslighting => 'Gaslighting',
        pressureTactic => 'Pressure Tactic',
        misleading => 'Misleading',
        unclear => 'Unclear',
      };

  String get jsonValue => switch (this) {
        manipulation => 'manipulation',
        legalRisk => 'legal_risk',
        hiddenCost => 'hidden_cost',
        gaslighting => 'gaslighting',
        pressureTactic => 'pressure_tactic',
        misleading => 'misleading',
        unclear => 'unclear',
      };

  static FlagType fromJson(String value) => switch (value.toLowerCase()) {
        'manipulation' => manipulation,
        'legal_risk' => legalRisk,
        'hidden_cost' => hiddenCost,
        'gaslighting' => gaslighting,
        'pressure_tactic' => pressureTactic,
        'misleading' => misleading,
        'unclear' => unclear,
        _ => unclear,
      };
}

/// A flagged phrase with explanation.
class RedFlag {
  const RedFlag({
    required this.text,
    required this.reason,
    required this.severity,
    required this.type,
  });

  final String text;
  final String reason;
  final RiskLevel severity;
  final FlagType type;

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      text: json['text'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      severity: RiskLevel.fromJson(json['severity'] as String? ?? 'safe'),
      type: FlagType.fromJson(json['type'] as String? ?? 'unclear'),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'reason': reason,
        'severity': severity.name,
        'type': type.jsonValue,
      };
}

/// The result returned from AI analysis.
class AnalysisResult {
  const AnalysisResult({
    required this.summary,
    required this.riskLevel,
    required this.manipulationScore,
    required this.flags,
    required this.keyPoints,
    required this.hiddenMeanings,
    this.suggestedResponse,
    required this.toneAnalysis,
    required this.category,
  });

  final String summary;
  final RiskLevel riskLevel;
  final int manipulationScore;
  final List<RedFlag> flags;
  final List<String> keyPoints;
  final List<String> hiddenMeanings;
  final String? suggestedResponse;
  final String toneAnalysis;
  final String category;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      summary: json['summary'] as String? ?? '',
      riskLevel: RiskLevel.fromJson(json['risk_level'] as String? ?? 'safe'),
      manipulationScore: (json['manipulation_score'] as num?)?.toInt() ?? 0,
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keyPoints: (json['key_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hiddenMeanings: (json['hidden_meanings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      suggestedResponse: json['suggested_response'] as String?,
      toneAnalysis: json['tone_analysis'] as String? ?? 'neutral',
      category: json['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'risk_level': riskLevel.name,
        'manipulation_score': manipulationScore,
        'flags': flags.map((f) => f.toJson()).toList(),
        'key_points': keyPoints,
        'hidden_meanings': hiddenMeanings,
        'suggested_response': suggestedResponse,
        'tone_analysis': toneAnalysis,
        'category': category,
      };
}

/// A complete analysis entry.
class Analysis {
  Analysis({
    String? id,
    required this.inputText,
    required this.inputType,
    required this.result,
    DateTime? createdAt,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String inputText;
  final AnalysisType inputType;
  final AnalysisResult result;
  final DateTime createdAt;
  final bool isFavorite;

  Analysis copyWith({
    String? id,
    String? inputText,
    AnalysisType? inputType,
    AnalysisResult? result,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Analysis(
      id: id ?? this.id,
      inputText: inputText ?? this.inputText,
      inputType: inputType ?? this.inputType,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json['id'] as String,
      inputText: json['input_text'] as String,
      inputType: AnalysisType.fromJson(json['input_type'] as String),
      result:
          AnalysisResult.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'input_text': inputText,
        'input_type': inputType.jsonValue,
        'result': result.toJson(),
        'created_at': createdAt.toIso8601String(),
        'is_favorite': isFavorite,
      };

  /// Serialize to a JSON string for Hive storage.
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize from a JSON string from Hive storage.
  factory Analysis.fromJsonString(String source) {
    return Analysis.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
