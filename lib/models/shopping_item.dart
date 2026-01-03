/// Shopping list item model.
class ShoppingItem {
  final String id;
  final String name;
  final String? quantity;
  final String? unit;
  final String? category;
  final bool isChecked;
  final String? recipeId;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    this.isChecked = false,
    this.recipeId,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? unit,
    String? category,
    bool? isChecked,
    String? recipeId,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isChecked': isChecked,
      'recipeId': recipeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'],
      unit: json['unit'],
      category: json['category'],
      isChecked: json['isChecked'] ?? false,
      recipeId: json['recipeId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Create a new item with generated ID.
  factory ShoppingItem.create({
    required String name,
    String? quantity,
    String? unit,
    String? category,
    String? recipeId,
  }) {
    return ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      recipeId: recipeId,
      createdAt: DateTime.now(),
    );
  }
}

/// Shopping list containing multiple items.
class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get checked items count.
  int get checkedCount => items.where((i) => i.isChecked).length;
  
  /// Get total items count.
  int get totalCount => items.length;

  /// Get progress percentage.
  double get progress => totalCount > 0 ? checkedCount / totalCount : 0;

  /// Check if all items are checked.
  bool get isComplete => totalCount > 0 && checkedCount == totalCount;

  /// Get items grouped by category.
  Map<String, List<ShoppingItem>> get itemsByCategory {
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      final category = item.category ?? 'Diğer';
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  ShoppingList copyWith({
    String? id,
    String? name,
    List<ShoppingItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      items: (json['items'] as List?)
              ?.map((i) => ShoppingItem.fromJson(i))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Create a new list with generated ID.
  factory ShoppingList.create({required String name}) {
    return ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );
  }
}

/// Common shopping categories.
class ShoppingCategories {
  static const String produce = 'Meyve & Sebze';
  static const String dairy = 'Süt Ürünleri';
  static const String meat = 'Et & Balık';
  static const String bakery = 'Fırın Ürünleri';
  static const String pantry = 'Kuru Gıda';
  static const String frozen = 'Dondurulmuş';
  static const String beverages = 'İçecekler';
  static const String snacks = 'Atıştırmalık';
  static const String household = 'Ev Gereçleri';
  static const String other = 'Diğer';

  static const List<String> all = [
    produce,
    dairy,
    meat,
    bakery,
    pantry,
    frozen,
    beverages,
    snacks,
    household,
    other,
  ];

  /// Get category icon.
  static String getIcon(String category) {
    switch (category) {
      case produce:
        return '🥬';
      case dairy:
        return '🥛';
      case meat:
        return '🥩';
      case bakery:
        return '🍞';
      case pantry:
        return '🥫';
      case frozen:
        return '🧊';
      case beverages:
        return '🥤';
      case snacks:
        return '🍿';
      case household:
        return '🧹';
      default:
        return '📦';
    }
  }
}
