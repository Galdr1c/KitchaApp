/// Public user profile model.
class PublicProfile {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int totalRecipes;
  final int totalFavorites;
  final int followersCount;
  final int followingCount;
  final List<String> badges;
  final int totalXP;
  final int currentLevel;
  final bool isPremium;
  final DateTime joinedAt;
  final bool isFollowing;

  const PublicProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.totalRecipes,
    required this.totalFavorites,
    required this.followersCount,
    required this.followingCount,
    required this.badges,
    required this.totalXP,
    required this.currentLevel,
    required this.isPremium,
    required this.joinedAt,
    this.isFollowing = false,
  });

  String get rankTitle {
    if (currentLevel >= 10) return 'Master Şef';
    if (currentLevel >= 7) return 'Gurme';
    if (currentLevel >= 5) return 'Mutfak Ustası';
    if (currentLevel >= 3) return 'Aşçı';
    return 'Çırak';
  }

  PublicProfile copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    String? bio,
    int? totalRecipes,
    int? totalFavorites,
    int? followersCount,
    int? followingCount,
    List<String>? badges,
    int? totalXP,
    int? currentLevel,
    bool? isPremium,
    DateTime? joinedAt,
    bool? isFollowing,
  }) {
    return PublicProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalRecipes: totalRecipes ?? this.totalRecipes,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      badges: badges ?? this.badges,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      isPremium: isPremium ?? this.isPremium,
      joinedAt: joinedAt ?? this.joinedAt,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'totalRecipes': totalRecipes,
      'totalFavorites': totalFavorites,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'badges': badges,
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'isPremium': isPremium,
      'joinedAt': joinedAt.toIso8601String(),
      'isFollowing': isFollowing,
    };
  }

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Anonim',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      totalRecipes: json['totalRecipes'] ?? 0,
      totalFavorites: json['totalFavorites'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      totalXP: json['totalXP'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      isPremium: json['isPremium'] ?? false,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  /// Create mock profile for demo.
  factory PublicProfile.mock(String userId) {
    return PublicProfile(
      userId: userId,
      username: 'Demo User',
      bio: 'Mutfak tutkunu 🍳',
      totalRecipes: 15,
      totalFavorites: 42,
      followersCount: 128,
      followingCount: 56,
      badges: ['first_recipe', 'collector', 'streak_7'],
      totalXP: 1250,
      currentLevel: 5,
      isPremium: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
    );
  }
}
