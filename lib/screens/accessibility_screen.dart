import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

/// Screen for accessibility settings including color blindness filters.
class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccessibilityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erişilebilirlik'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Color Blindness Section
          const Text(
            'Renk Körlüğü Filtreleri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Görme tercihlerinize uygun renk filtresi seçin',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Preview Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'Renk Önizleme',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter Options
          ...ColorBlindMode.values.map((mode) => _buildFilterOption(
                context,
                mode,
                provider.getModeName(mode),
                provider.getModeDescription(mode),
                provider,
              )),

          const Divider(height: 40),

          // Text Size Section
          const Text(
            'Metin Boyutu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: provider.textScaleFactor,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(provider.textScaleFactor * 100).toInt()}%',
                  onChanged: (value) {
                    provider.setTextScaleFactor(value);
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),

          const Divider(height: 40),

          // Reduce Motion Section
          SwitchListTile(
            title: const Text('Hareketleri Azalt'),
            subtitle: const Text('Animasyonları en aza indirir'),
            value: provider.reduceMotion,
            onChanged: (value) {
              provider.setReduceMotion(value);
            },
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Değişiklikler anında uygulanır ve kaydedilir.',
                    style: TextStyle(
                      color: isDark ? Colors.blue[200] : Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    ColorBlindMode mode,
    String title,
    String description,
    AccessibilityProvider provider,
  ) {
    return RadioListTile<ColorBlindMode>(
      title: Text(title),
      subtitle: Text(description),
      value: mode,
      groupValue: provider.currentMode,
      onChanged: (value) {
        if (value != null) {
          provider.setMode(value);
        }
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }
}
