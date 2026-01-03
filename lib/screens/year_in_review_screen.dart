import 'package:flutter/material.dart';
import '../models/year_in_review.dart';
import '../services/haptic_service.dart';

/// Year in Review screen (Spotify Wrapped style).
class YearInReviewScreen extends StatefulWidget {
  final YearInReviewData data;

  const YearInReviewScreen({super.key, required this.data});

  @override
  State<YearInReviewScreen> createState() => _YearInReviewScreenState();
}

class _YearInReviewScreenState extends State<YearInReviewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Color> _slideColors = [
    const Color(0xFFFF6347), // Tomato
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF607D8B), // Summary
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slideColors[_currentPage],
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  HapticService.light();
                },
                children: [
                  _buildWelcomeSlide(),
                  _buildRecipesSlide(),
                  _buildCategoriesSlide(),
                  _buildCaloriesSlide(),
                  _buildStreakSlide(),
                  _buildAchievementsSlide(),
                  _buildSummarySlide(),
                ],
              ),
            ),

            // Indicators
            _buildIndicators(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String emoji,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeSlide() {
    return _buildSlide(
      emoji: '🍳',
      title: 'Mutfakta geçirdiğin',
      value: '${widget.data.year}',
      subtitle: 'Harika bir yıldı!',
    );
  }

  Widget _buildRecipesSlide() {
    return _buildSlide(
      emoji: '📖',
      title: 'Bu yıl incelediğin tarif',
      value: '${widget.data.totalRecipesViewed}',
      subtitle: 'Kullanıcıların en iyi %${widget.data.percentile}\'ndesin!',
    );
  }

  Widget _buildCategoriesSlide() {
    return _buildSlide(
      emoji: '⭐',
      title: 'En çok baktığın kategori',
      value: widget.data.mostViewedCategory,
      subtitle: 'Sen bir ${widget.data.personalityType}\'sin!',
    );
  }

  Widget _buildCaloriesSlide() {
    return _buildSlide(
      emoji: '🔥',
      title: 'Hesapladığın toplam kalori',
      value: '${widget.data.totalCalories}',
      subtitle: 'Yaklaşık ${widget.data.calorieEquivalent}',
    );
  }

  Widget _buildStreakSlide() {
    return _buildSlide(
      emoji: '🏆',
      title: 'En uzun serin',
      value: '${widget.data.consecutiveDays} gün',
      subtitle: 'Harika bir tutarlılık!',
    );
  }

  Widget _buildAchievementsSlide() {
    return _buildSlide(
      emoji: '🎖️',
      title: 'Kazandığın rozetler',
      value: '${widget.data.badgesEarned}',
      subtitle: '+${widget.data.xpGained} XP',
    );
  }

  Widget _buildSummarySlide() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          const Text(
            'Yıl Özeti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('📖 Tarifler', '${widget.data.totalRecipesViewed}'),
          _buildSummaryRow('❤️ Favoriler', '${widget.data.totalFavorites}'),
          _buildSummaryRow('📷 Analizler', '${widget.data.totalAnalyses}'),
          _buildSummaryRow('🔥 Kalori', '${widget.data.totalCalories}'),
          _buildSummaryRow('⭐ XP', '${widget.data.xpGained}'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share),
            label: const Text('Paylaş'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _slideColors[_currentPage],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        return Container(
          width: _currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_currentPage == index ? 1 : 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
