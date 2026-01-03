import 'package:flutter/material.dart';
import '../services/social_service.dart';
import '../services/gamification_service.dart';

/// Widget displaying user profile statistics.
class ProfileStatsWidget extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  const ProfileStatsWidget({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, int>>(
      future: _getStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: Row(
            children: [
              _buildStatItem(
                context,
                label: 'Tarif',
                value: stats['recipes'] ?? 0,
                icon: Icons.restaurant_menu,
              ),
              _buildDivider(isDark),
              _buildStatItem(
                context,
                label: 'Takipçi',
                value: stats['followers'] ?? 0,
                icon: Icons.people,
                onTap: () => _showFollowers(context),
              ),
              _buildDivider(isDark),
              _buildStatItem(
                context,
                label: 'Takip',
                value: stats['following'] ?? 0,
                icon: Icons.person_add,
                onTap: () => _showFollowing(context),
              ),
              _buildDivider(isDark),
              _buildStatItem(
                context,
                label: 'XP',
                value: stats['xp'] ?? 0,
                icon: Icons.star,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _getStats() async {
    final social = SocialService();
    final gamification = GamificationService();

    return {
      'recipes': 0, // Would fetch from recipe service
      'followers': await social.getFollowersCount(userId),
      'following': await social.getFollowingCount(userId),
      'xp': 0, // Would fetch from gamification service
    };
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF6347), size: 20),
            const SizedBox(height: 4),
            Text(
              _formatNumber(value),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  void _showFollowers(BuildContext context) {
    // Navigate to followers list
  }

  void _showFollowing(BuildContext context) {
    // Navigate to following list
  }
}

/// Follow button widget.
class FollowButton extends StatefulWidget {
  final String targetUserId;
  final bool initiallyFollowing;

  const FollowButton({
    super.key,
    required this.targetUserId,
    this.initiallyFollowing = false,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final SocialService _social = SocialService();
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initiallyFollowing;
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final following = await _social.isFollowing(widget.targetUserId);
    if (mounted) {
      setState(() => _isFollowing = following);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isLoading = true);

    bool success;
    if (_isFollowing) {
      success = await _social.unfollowUser(widget.targetUserId);
    } else {
      success = await _social.followUser(widget.targetUserId);
    }

    if (success && mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isFollowing ? Colors.grey[300] : const Color(0xFFFF6347),
        foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_isFollowing ? 'Takipten Çık' : 'Takip Et'),
    );
  }
}
