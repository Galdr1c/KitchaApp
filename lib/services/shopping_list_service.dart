import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shopping_item.dart';
import 'analytics_service.dart';

/// Service for managing shopping lists.
class ShoppingListService {
  static final ShoppingListService _instance = ShoppingListService._internal();
  factory ShoppingListService() => _instance;
  ShoppingListService._internal();

  static const String _storageKey = 'shopping_lists';
  final AnalyticsService _analytics = AnalyticsService();

  /// Get all shopping lists.
  Future<List<ShoppingList>> getAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = prefs.getString(_storageKey);
    
    if (listsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(listsJson);
      return decoded.map((json) => ShoppingList.fromJson(json)).toList();
    } catch (e) {
      print('[ShoppingListService] Error loading lists: $e');
      return [];
    }
  }

  /// Save all lists.
  Future<void> _saveLists(List<ShoppingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(lists.map((l) => l.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  /// Create a new shopping list.
  Future<ShoppingList> createList(String name) async {
    final lists = await getAllLists();
    final newList = ShoppingList.create(name: name);
    lists.insert(0, newList);
    await _saveLists(lists);
    
    await _analytics.logShoppingListCreated(0);
    
    return newList;
  }

  /// Delete a shopping list.
  Future<void> deleteList(String listId) async {
    final lists = await getAllLists();
    lists.removeWhere((l) => l.id == listId);
    await _saveLists(lists);
  }

  /// Add item to a list.
  Future<ShoppingList?> addItem(
    String listId, {
    required String name,
    String? quantity,
    String? unit,
    String? category,
    String? recipeId,
  }) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == listId);
    
    if (index == -1) return null;

    final item = ShoppingItem.create(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      recipeId: recipeId,
    );

    final updatedList = lists[index].copyWith(
      items: [...lists[index].items, item],
      updatedAt: DateTime.now(),
    );

    lists[index] = updatedList;
    await _saveLists(lists);
    
    await _analytics.logShoppingListCreated(updatedList.items.length);

    return updatedList;
  }

  /// Remove item from a list.
  Future<ShoppingList?> removeItem(String listId, String itemId) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == listId);
    
    if (index == -1) return null;

    final updatedItems = lists[index].items
        .where((i) => i.id != itemId)
        .toList();

    final updatedList = lists[index].copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    lists[index] = updatedList;
    await _saveLists(lists);

    return updatedList;
  }

  /// Toggle item checked status.
  Future<ShoppingList?> toggleItem(String listId, String itemId) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == listId);
    
    if (index == -1) return null;

    final updatedItems = lists[index].items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();

    final updatedList = lists[index].copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    lists[index] = updatedList;
    await _saveLists(lists);

    return updatedList;
  }

  /// Add multiple items from a recipe.
  Future<ShoppingList?> addItemsFromRecipe(
    String listId,
    String recipeId,
    List<String> ingredients,
  ) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == listId);
    
    if (index == -1) return null;

    final newItems = ingredients.map((ingredient) {
      return ShoppingItem.create(
        name: ingredient,
        recipeId: recipeId,
      );
    }).toList();

    final updatedList = lists[index].copyWith(
      items: [...lists[index].items, ...newItems],
      updatedAt: DateTime.now(),
    );

    lists[index] = updatedList;
    await _saveLists(lists);

    return updatedList;
  }

  /// Clear checked items from a list.
  Future<ShoppingList?> clearCheckedItems(String listId) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == listId);
    
    if (index == -1) return null;

    final updatedItems = lists[index].items
        .where((i) => !i.isChecked)
        .toList();

    final updatedList = lists[index].copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    lists[index] = updatedList;
    await _saveLists(lists);

    return updatedList;
  }

  /// Get a specific list by ID.
  Future<ShoppingList?> getList(String listId) async {
    final lists = await getAllLists();
    try {
      return lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }
}
