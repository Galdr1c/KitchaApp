import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../services/analytics_service.dart';

/// Premium subscription paywall screen.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().logPremiumPaywallShown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Color(0xFFFF6347),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kitcha Plus',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sınırsız tarifler, AI özellikleri ve daha fazlası',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Feature Comparison
                _buildFeatureComparison(),

                const SizedBox(height: 24),

                // Error message
                if (subscriptionProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subscriptionProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Pricing Cards
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildPricingCard(
                        title: 'Aylık',
                        price: '₺39.99',
                        period: '/ay',
                        onTap: subscriptionProvider.isLoading
                            ? null
                            : () => subscriptionProvider.buyMonthly(),
                        isPrimary: false,
                        isLoading: subscriptionProvider.isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildPricingCard(
                        title: 'Ömür Boyu',
                        price: '₺299.99',
                        period: 'tek seferlik',
                        badge: 'EN İYİ DEĞER',
                        onTap: subscriptionProvider.isLoading
                            ? null
                            : () => subscriptionProvider.buyLifetime(),
                        isPrimary: true,
                        isLoading: subscriptionProvider.isLoading,
                      ),
                    ],
                  ),
                ),

                // Restore Purchases
                TextButton(
                  onPressed: subscriptionProvider.isLoading
                      ? null
                      : () => subscriptionProvider.restorePurchases(),
                  child: Text(
                    'Satın Alımları Geri Yükle',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildComparisonHeader(),
          _buildComparisonRow('Temel Tarifler', true, true),
          _buildComparisonRow('Kalori Hesaplama', '1/gün', '∞'),
          _buildComparisonRow('Reklamlar', true, false),
          _buildComparisonRow('Yemek Planlayıcı', false, true),
          _buildComparisonRow('AI Özellikleri', false, true),
          _buildComparisonRow('Alışveriş Listesi Paylaşım', false, true),
          _buildComparisonRow('Öncelikli Destek', false, true),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'Özellik',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ücretsiz',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            child: Text(
              'Plus',
              style: TextStyle(
                color: Color(0xFFFF6347),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, dynamic free, dynamic premium) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _buildCheckOrText(free),
          ),
          Expanded(
            child: _buildCheckOrText(premium, isPremium: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOrText(dynamic value, {bool isPremium = false}) {
    final color = isPremium ? const Color(0xFFFF6347) : Colors.grey[600];

    if (value is bool) {
      return Center(
        child: value
            ? Icon(Icons.check, color: color)
            : Icon(Icons.close, color: Colors.grey[700]),
      );
    } else {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyle(color: color),
        ),
      );
    }
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    String? badge,
    VoidCallback? onTap,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
                )
              : null,
          color: isPrimary ? null : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFF3A3A3A),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' $period',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
