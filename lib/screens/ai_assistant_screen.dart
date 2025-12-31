import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/memory_mcp_service.dart';
import '../services/recipe_mcp_service.dart';
import '../providers/recipe_provider.dart';
import '../repository/app_repository.dart';
import '../theme/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final MemoryMcpService _memoryMcp = MemoryMcpService();
  final RecipeMcpService _recipeMcp = RecipeMcpService();
  bool _isLoading = false;

  final List<String> _quickActions = [
    "Bugün ne pişirsem?",
    "Kalori hesapla",
    "Hafif bir tarif öner",
    "Menü planla",
  ];

  @override
  void initState() {
    super.initState();
    _addSystemMessage('Merhaba! Ben Kitcha asistanınız. Yemek tercihlerinizden öğrenip size özel öneriler sunabilirim. Bugün ne pişirmemizi istersiniz?');
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add({'role': 'assistant', 'text': text});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? textOverride]) async {
    final text = textOverride ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (textOverride == null) _controller.clear();
    
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final context = await _memoryMcp.searchContext(text);
      
      if (text.toLowerCase().contains('ne pişirsem') || 
          text.toLowerCase().contains('öneri') || 
          text.toLowerCase().contains('tarif')) {
        
        final recipes = await _recipeMcp.searchRecipesByIngredients(text.length > 10 ? text : 'popüler');
        
        setState(() {
          _messages.add({
            'role': 'assistant', 
            'text': 'Hafızandaki tercihlere (örn: $context) göre şunları önerebilirim:',
            'recipes': recipes.take(3).toList(),
          });
        });
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _addSystemMessage('Anladım. Hafızanda "$context" gibi bilgiler var. Bu bilgileri kullanarak sana mutfakta en iyi şekilde yardımcı olacağım.');
      }
    } catch (e) {
      _addSystemMessage('Üzgünüm, bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addSystemMessage('Sohbet temizlendi. Nasıl yardımcı olabilirim?');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('AI Asistan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Sohbeti temizle',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: FadeInAnimation(
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: _buildChatBubble(msg),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoading) _buildTypingIndicator(),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Text(
            'Kitcha AI düşünüyor...',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(_quickActions[index]),
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 1,
            onPressed: () => _handleSendMessage(_quickActions[index]),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isAssistant = msg['role'] == 'assistant';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isAssistant 
                ? (isDark ? const Color(0xFF2D2D2D) : Colors.white)
                : AppTheme.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isAssistant ? 4 : 20),
              bottomRight: Radius.circular(isAssistant ? 20 : 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg['text'],
            style: TextStyle(
              fontSize: 15,
              color: isAssistant ? (isDark ? Colors.white : Colors.black87) : Colors.white,
            ),
          ),
        ),
        if (msg['recipes'] != null) _buildRecipeSuggestions(msg['recipes']),
      ],
    );
  }

  Widget _buildRecipeSuggestions(List<dynamic> recipes) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (context, i) {
          final recipe = recipes[i] as RecipeModel;
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/recipeDetail', arguments: recipe),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: recipe.imageUrl.isNotEmpty
                          ? Image.network(recipe.imageUrl, fit: BoxFit.cover, width: double.infinity)
                          : Container(color: Colors.grey[300], child: const Icon(Icons.restaurant)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${recipe.calories} kkal • ${recipe.totalTime} dk',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.mic, color: AppTheme.primaryColor),
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _handleSendMessage(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
