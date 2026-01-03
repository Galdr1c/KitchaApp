import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detected_ingredient.dart';
import '../services/ingredient_detection_service.dart';
import '../services/haptic_service.dart';

/// Snap & Cook AI Camera Screen for ingredient detection.
class AIKitchenCameraScreen extends StatefulWidget {
  const AIKitchenCameraScreen({super.key});

  @override
  State<AIKitchenCameraScreen> createState() => _AIKitchenCameraScreenState();
}

class _AIKitchenCameraScreenState extends State<AIKitchenCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final IngredientDetectionService _detectionService = IngredientDetectionService();
  final TextEditingController _manualController = TextEditingController();

  File? _image;
  List<DetectedIngredient> _detectedIngredients = [];
  List<RecipeMatch> _suggestedRecipes = [];
  bool _isDetecting = false;
  bool _isFindingRecipes = false;
  int _currentStep = 0; // 0: empty, 1: detected, 2: recipes

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap & Cook AI 🍳'),
        backgroundColor: const Color(0xFFFF6347),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: _currentStep == 0
          ? FloatingActionButton.extended(
              onPressed: _showImageSourceDialog,
              label: const Text('Fotoğraf Çek'),
              icon: const Icon(Icons.camera_alt),
              backgroundColor: const Color(0xFFFF6347),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isDetecting) {
      return _buildLoadingState('Malzemeler Taranıyor...');
    }

    if (_isFindingRecipes) {
      return _buildLoadingState('Tarifler Aranıyor...');
    }

    switch (_currentStep) {
      case 0:
        return _buildEmptyState();
      case 1:
        return _buildIngredientsState();
      case 2:
        return _buildRecipesState();
      default:
        return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Mutfağını Fotoğrafla',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Buzdolabı veya mutfağındaki malzemeleri çek, sana tarif önerelim!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF6347)),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildIngredientsState() {
    return Column(
      children: [
        // Image preview
        if (_image != null)
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black12,
            child: Image.file(_image!, fit: BoxFit.cover),
          ),

        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Bulunan Malzemeler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addManualIngredient,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ekle'),
              ),
            ],
          ),
        ),

        // Ingredients list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _detectedIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = _detectedIngredients[index];
              return _buildIngredientTile(ingredient);
            },
          ),
        ),

        // Find recipes button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _findRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6347),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tarif Bul (${_detectedIngredients.where((i) => i.isSelected).length} malzeme)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientTile(DetectedIngredient ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: ingredient.isSelected,
        onChanged: (value) {
          setState(() => ingredient.isSelected = value ?? false);
          HapticService.light();
        },
        title: Text(
          ingredient.displayName,
          style: TextStyle(
            decoration: ingredient.isSelected ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: ingredient.isHighConfidence
            ? null
            : Text(
                'Güven: ${ingredient.confidencePercent}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ingredient.isHighConfidence
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            ingredient.confidencePercent,
            style: TextStyle(
              color: ingredient.isHighConfidence ? Colors.green : Colors.orange,
              fontSize: 12,
            ),
          ),
        ),
        activeColor: const Color(0xFFFF6347),
      ),
    );
  }

  Widget _buildRecipesState() {
    return Column(
      children: [
        // Back button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentStep = 1),
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                'Önerilen Tarifler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Recipes list
        Expanded(
          child: _suggestedRecipes.isEmpty
              ? _buildNoRecipesState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestedRecipes.length,
                  itemBuilder: (context, index) {
                    final match = _suggestedRecipes[index];
                    return _buildRecipeMatchCard(match);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoRecipesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Tarif Bulunamadı', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            'Daha fazla malzeme ekleyin',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeMatchCard(RecipeMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
          HapticService.light();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and match percentage
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.recipe.titleTR,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: match.matchPercentage > 0.7
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match.matchPercentDisplay,
                      style: TextStyle(
                        color: match.matchPercentage > 0.7
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Matched ingredients
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: match.matchedIngredients.take(5).map((ing) {
                  return Chip(
                    label: Text(ing, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),

              // Missing ingredients
              if (match.missingCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Eksik: ${match.missingIngredients.take(3).join(", ")}${match.missingCount > 3 ? " +${match.missingCount - 3}" : ""}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isDetecting = true;
    });

    try {
      final ingredients = await _detectionService.detectIngredients(_image!);
      setState(() {
        _detectedIngredients = ingredients;
        _currentStep = 1;
      });
      HapticService.success();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  void _addManualIngredient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Malzeme Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _manualController,
              decoration: const InputDecoration(
                hintText: 'Malzeme adı',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _detectionService.getCommonIngredients().take(6).map((ing) {
                return ActionChip(
                  label: Text(ing),
                  onPressed: () {
                    _addIngredient(ing);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_manualController.text.isNotEmpty) {
                _addIngredient(_manualController.text);
                _manualController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addIngredient(String name) {
    final ingredient = _detectionService.addManualIngredient(name);
    setState(() => _detectedIngredients.add(ingredient));
    HapticService.light();
  }

  Future<void> _findRecipes() async {
    setState(() => _isFindingRecipes = true);

    try {
      final recipes = await _detectionService.findMatchingRecipes(_detectedIngredients);
      setState(() {
        _suggestedRecipes = recipes;
        _currentStep = 2;
      });
      HapticService.success();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isFindingRecipes = false);
    }
  }
}
