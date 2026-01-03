import 'package:flutter/material.dart';
import '../services/seasonal_service.dart';

/// Overlay widget that adds seasonal animations over content.
class SeasonalOverlay extends StatelessWidget {
  final Widget child;

  const SeasonalOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final seasonalService = SeasonalService();
    final currentTheme = seasonalService.getCurrentTheme();

    if (currentTheme == SeasonalTheme.none) {
      return child;
    }

    final themeData = seasonalService.getThemeData(currentTheme);
    if (themeData == null) return child;

    return Stack(
      children: [
        child,

        // Animated overlay (using simple particle effect placeholder)
        // In production, use Lottie.asset(themeData.animationAsset)
        Positioned.fill(
          child: IgnorePointer(
            child: _buildParticleOverlay(themeData),
          ),
        ),
      ],
    );
  }

  Widget _buildParticleOverlay(SeasonalThemeData themeData) {
    // Simple emoji animation placeholder
    // In production, replace with Lottie animation
    return AnimatedOpacity(
      opacity: 0.3,
      duration: const Duration(seconds: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: themeData.emojis
                  .map((emoji) => Text(emoji, style: const TextStyle(fontSize: 20)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header widget that shows seasonal greeting.
class SeasonalHeader extends StatelessWidget {
  const SeasonalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final seasonalService = SeasonalService();
    final currentTheme = seasonalService.getCurrentTheme();

    if (currentTheme == SeasonalTheme.none) {
      return const SizedBox.shrink();
    }

    final themeData = seasonalService.getThemeData(currentTheme);
    if (themeData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: themeData.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeData.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            themeData.emojis.join(' '),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  themeData.greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (themeData.suggestedCategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      themeData.suggestedCategories.take(3).join(' • '),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}

/// Compact seasonal badge widget.
class SeasonalBadge extends StatelessWidget {
  const SeasonalBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final seasonalService = SeasonalService();
    final themeData = seasonalService.getCurrentThemeData();

    if (themeData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: themeData.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(themeData.emojis.first, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            themeData.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seasonal floating action button decoration.
class SeasonalFABDecoration extends StatelessWidget {
  final Widget child;

  const SeasonalFABDecoration({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeData = SeasonalService().getCurrentThemeData();

    if (themeData == null) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8,
          right: -8,
          child: Text(
            themeData.emojis.first,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
