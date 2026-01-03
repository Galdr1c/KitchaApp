import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../services/ad_manager.dart';

/// Widget that displays a banner ad at the bottom of screens.
/// Automatically hides for premium users.
/// 
/// Note: Full implementation requires google_mobile_ads package.
/// This provides the structure and premium-check logic.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdManager _adManager = AdManager();
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // This would be actual ad loading with google_mobile_ads:
    // _bannerAd = BannerAd(
    //   adUnitId: _adManager.bannerAdUnitId,
    //   size: AdSize.banner,
    //   request: const AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) => setState(() => _isAdLoaded = true),
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //       print('BannerAd failed to load: $error');
    //     },
    //   ),
    // )..load();

    // For now, simulate ad loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAdLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    // Don't show ads to premium users
    if (subscriptionProvider.isPremium || !_isAdLoaded) {
      return const SizedBox.shrink();
    }

    // Placeholder for actual ad widget
    // When google_mobile_ads is added, replace with:
    // return Container(
    //   alignment: Alignment.center,
    //   width: _bannerAd!.size.width.toDouble(),
    //   height: _bannerAd!.size.height.toDouble(),
    //   child: AdWidget(ad: _bannerAd!),
    // );

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border(
          top: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: const Center(
        child: Text(
          'Ad Placeholder',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _bannerAd?.dispose();
    super.dispose();
  }
}

/// A floating banner ad widget with rounded corners.
class FloatingBannerAdWidget extends StatelessWidget {
  const FloatingBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    if (subscriptionProvider.isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: const BannerAdWidget(),
      ),
    );
  }
}
