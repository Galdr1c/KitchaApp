import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';
import 'analytics_service.dart';

/// Service for managing referral system.
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  static const int _referralRewardXP = 100;
  static const int _refereeRewardXP = 50;

  /// Generate a unique referral code for the user.
  Future<String> getOrCreateReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('my_referral_code');

    if (code != null) return code;

    // Generate new code
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final random = Random();
    final suffix = List.generate(4, (_) => random.nextInt(10)).join();
    code = 'KITCHA${userId.substring(0, 4).toUpperCase()}$suffix';

    await prefs.setString('my_referral_code', code);

    // Save to Firestore
    if (FirebaseService.isAvailable && userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'referralCode': code,
      }, SetOptions(merge: true));
    }

    return code;
  }

  /// Apply a referral code (for new users).
  Future<ReferralResult> applyReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if already used a referral
    if (prefs.getBool('referral_used') == true) {
      return ReferralResult(
        success: false,
        message: 'Daha önce bir referans kodu kullandınız.',
      );
    }

    // Check if it's own code
    final myCode = prefs.getString('my_referral_code');
    if (myCode == code) {
      return ReferralResult(
        success: false,
        message: 'Kendi referans kodunuzu kullanamazsınız.',
      );
    }

    // Validate code exists
    if (FirebaseService.isAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return ReferralResult(
          success: false,
          message: 'Geçersiz referans kodu.',
        );
      }

      final referrerId = snapshot.docs.first.id;

      // Reward referrer
      await FirebaseFirestore.instance.collection('users').doc(referrerId).update({
        'gamification.totalXP': FieldValue.increment(_referralRewardXP),
        'referralCount': FieldValue.increment(1),
      });

      // Reward referee (current user)
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
          'gamification.totalXP': FieldValue.increment(_refereeRewardXP),
          'referredBy': referrerId,
        });
      }
    }

    // Mark as used
    await prefs.setBool('referral_used', true);
    await prefs.setString('referral_code_used', code);

    // Log analytics
    await _analytics.logReferralApplied(code);

    return ReferralResult(
      success: true,
      message: '+$_refereeRewardXP XP kazandınız! 🎉',
      xpEarned: _refereeRewardXP,
    );
  }

  /// Get referral statistics.
  Future<ReferralStats> getStats() async {
    final code = await getOrCreateReferralCode();
    int referralCount = 0;
    int totalXPEarned = 0;

    if (FirebaseService.isAvailable) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists) {
          referralCount = doc.data()?['referralCount'] ?? 0;
          totalXPEarned = referralCount * _referralRewardXP;
        }
      }
    }

    return ReferralStats(
      referralCode: code,
      referralCount: referralCount,
      totalXPEarned: totalXPEarned,
      xpPerReferral: _referralRewardXP,
    );
  }

  /// Check if user has used a referral code.
  Future<bool> hasUsedReferral() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('referral_used') ?? false;
  }
}

/// Result of applying a referral code.
class ReferralResult {
  final bool success;
  final String message;
  final int? xpEarned;

  const ReferralResult({
    required this.success,
    required this.message,
    this.xpEarned,
  });
}

/// Referral statistics.
class ReferralStats {
  final String referralCode;
  final int referralCount;
  final int totalXPEarned;
  final int xpPerReferral;

  const ReferralStats({
    required this.referralCode,
    required this.referralCount,
    required this.totalXPEarned,
    required this.xpPerReferral,
  });
}
