/// Represents an authenticated Contextify user.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.tier = 'free',
    this.analysesCount = 0,
  });

  final int id;
  final String email;
  final String fullName;
  final String tier; // free, pro, lifetime
  final int analysesCount;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String? ?? '',
      tier: json['tier'] as String? ?? 'free',
      analysesCount: json['analysesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'tier': tier,
      'analysesCount': analysesCount,
    };
  }

  AppUser copyWith({
    int? id,
    String? email,
    String? fullName,
    String? tier,
    int? analysesCount,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      tier: tier ?? this.tier,
      analysesCount: analysesCount ?? this.analysesCount,
    );
  }
}
