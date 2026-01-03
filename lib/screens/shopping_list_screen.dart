import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_list_service.dart';

/// Screen for managing shopping lists.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListService _service = ShoppingListService();
  List<ShoppingList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);
    _lists = await _service.getAllLists();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş Listeleri'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lists.isEmpty
              ? _buildEmptyState(isDark)
              : _buildListView(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewList,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Liste'),
        backgroundColor: const Color(0xFFFF6347),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz alışveriş listeniz yok',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir liste oluşturun',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lists.length,
      itemBuilder: (context, index) {
        final list = _lists[index];
        return _buildListCard(list, isDark);
      },
    );
  }

  Widget _buildListCard(ShoppingList list, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openList(list),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteList(list),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${list.checkedCount}/${list.totalCount} tamamlandı',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (list.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✓ Tamamlandı',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: list.progress,
                  backgroundColor: isDark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6347),
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createNewList() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Liste'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Liste adı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6347),
            ),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _service.createList(result);
      _loadLists();
    }
  }

  Future<void> _deleteList(ShoppingList list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Listeyi Sil'),
        content: Text('"${list.name}" listesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteList(list.id);
      _loadLists();
    }
  }

  void _openList(ShoppingList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(listId: list.id),
      ),
    ).then((_) => _loadLists());
  }
}

/// Detail screen for a specific shopping list.
class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;

  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final ShoppingListService _service = ShoppingListService();
  ShoppingList? _list;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    setState(() => _isLoading = true);
    _list = await _service.getList(widget.listId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_list == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Liste Bulunamadı')),
        body: const Center(child: Text('Liste bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_list!.name),
        elevation: 0,
        actions: [
          if (_list!.items.any((i) => i.isChecked))
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: _clearChecked,
              tooltip: 'Tamamlananları temizle',
            ),
        ],
      ),
      body: _list!.items.isEmpty
          ? _buildEmptyState(isDark)
          : _buildItemsList(isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: const Color(0xFFFF6347),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_shopping_cart,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Liste boş',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(bool isDark) {
    final groupedItems = _list!.itemsByCategory;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedItems.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  ShoppingCategories.getIcon(entry.key),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...entry.value.map((item) => _buildItemTile(item, isDark)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildItemTile(ShoppingItem item, bool isDark) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: CheckboxListTile(
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked
                ? (isDark ? Colors.grey[500] : Colors.grey)
                : null,
          ),
        ),
        subtitle: item.quantity != null
            ? Text('${item.quantity} ${item.unit ?? ''}')
            : null,
        value: item.isChecked,
        onChanged: (_) => _toggleItem(item),
        activeColor: const Color(0xFFFF6347),
      ),
    );
  }

  Future<void> _addItem() async {
    final controller = TextEditingController();
    String? selectedCategory;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ürün Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ürün adı',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: ShoppingCategories.all.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text('${ShoppingCategories.getIcon(cat)} $cat'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': controller.text,
                'category': selectedCategory ?? ShoppingCategories.other,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6347),
              ),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['name']!.isNotEmpty) {
      await _service.addItem(
        widget.listId,
        name: result['name']!,
        category: result['category'],
      );
      _loadList();
    }
  }

  Future<void> _toggleItem(ShoppingItem item) async {
    await _service.toggleItem(widget.listId, item.id);
    _loadList();
  }

  Future<void> _removeItem(ShoppingItem item) async {
    await _service.removeItem(widget.listId, item.id);
    _loadList();
  }

  Future<void> _clearChecked() async {
    await _service.clearCheckedItems(widget.listId);
    _loadList();
  }
}
