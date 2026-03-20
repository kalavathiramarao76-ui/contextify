import '../models/analysis.dart';

/// Text utility helpers for Contextify.
abstract final class TextUtils {
  /// Truncate [text] to [maxLength] characters, appending an ellipsis if needed.
  static String truncateText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}...';
  }

  /// Count the number of words in [text].
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Auto-detect the probable [AnalysisType] based on keyword heuristics.
  static AnalysisType detectInputType(String text) {
    final lower = text.toLowerCase();

    // Contract indicators
    const contractKeywords = [
      'hereby',
      'agreement',
      'terms and conditions',
      'binding',
      'whereas',
      'party',
      'clause',
      'indemnify',
      'liability',
      'warrant',
      'governing law',
      'jurisdiction',
      'arbitration',
      'terminate',
      'breach',
      'obligations',
    ];

    // Medical bill indicators
    const medicalKeywords = [
      'patient',
      'diagnosis',
      'procedure',
      'cpt',
      'icd',
      'insurance',
      'copay',
      'deductible',
      'claim',
      'provider',
      'facility fee',
      'out-of-pocket',
      'eob',
      'explanation of benefits',
      'billing',
      'medical record',
    ];

    // Email indicators
    const emailKeywords = [
      'subject:',
      'from:',
      'to:',
      'dear ',
      'regards',
      'sincerely',
      'best regards',
      'kind regards',
      'cc:',
      'bcc:',
      'forwarded message',
      'reply to',
    ];

    // Social media indicators
    const socialKeywords = [
      '#',
      '@',
      'followers',
      'retweet',
      'dm',
      'story',
      'posted',
      'liked',
      'comment',
      'shared',
      'bio',
      'thread',
    ];

    int score(List<String> keywords) {
      return keywords.where((k) => lower.contains(k)).length;
    }

    final scores = {
      AnalysisType.contract: score(contractKeywords),
      AnalysisType.medicalBill: score(medicalKeywords),
      AnalysisType.email: score(emailKeywords),
      AnalysisType.socialMedia: score(socialKeywords),
    };

    final best = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (best.first.value >= 2) return best.first.key;

    // Default to message for short text, general for longer text.
    return countWords(text) < 50 ? AnalysisType.message : AnalysisType.general;
  }

  /// Return a human-readable relative time string for [dateTime].
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final m = diff.inDays ~/ 30;
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    }

    final y = diff.inDays ~/ 365;
    return '$y ${y == 1 ? 'year' : 'years'} ago';
  }
}
