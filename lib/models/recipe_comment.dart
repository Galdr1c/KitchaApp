/// Recipe comment model.
class RecipeComment {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String text;
  final List<String> images;
  final int helpfulCount;
  final DateTime createdAt;
  final bool isEdited;
  final bool isPremium;

  const RecipeComment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.text,
    this.images = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    this.isEdited = false,
    this.isPremium = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 0) return '${diff.inDays}g önce';
    if (diff.inHours > 0) return '${diff.inHours}s önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes}d önce';
    return 'Şimdi';
  }

  RecipeComment copyWith({
    String? id,
    String? recipeId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? text,
    List<String>? images,
    int? helpfulCount,
    DateTime? createdAt,
    bool? isEdited,
  }) {
    return RecipeComment(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      images: images ?? this.images,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'text': text,
      'images': images,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'isEdited': isEdited,
    };
  }

  factory RecipeComment.fromJson(Map<String, dynamic> json) {
    return RecipeComment(
      id: json['id'] ?? '',
      recipeId: json['recipeId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonim',
      userAvatar: json['userAvatar'],
      rating: json['rating'] ?? 5,
      text: json['text'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isEdited: json['isEdited'] ?? false,
    );
  }
}

/// Recipe rating summary.
class RecipeRating {
  final String recipeId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;

  const RecipeRating({
    required this.recipeId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RecipeRating.empty(String recipeId) {
    return RecipeRating(
      recipeId: recipeId,
      averageRating: 0,
      totalRatings: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }

  factory RecipeRating.fromJson(Map<String, dynamic> json) {
    return RecipeRating(
      recipeId: json['recipeId'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}),
    );
  }
}
