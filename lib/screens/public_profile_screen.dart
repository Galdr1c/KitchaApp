import 'package:flutter/material.dart';
import '../models/public_profile.dart';
import '../services/social_service.dart';
import '../widgets/profile_stats_widget.dart';

/// Screen displaying a user's public profile.
class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final SocialService _social = SocialService();
  PublicProfile? _profile;
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Use mock for now
    _profile = PublicProfile.mock(widget.userId);
    _isFollowing = await _social.isFollowing(widget.userId);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Cover & avatar
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -50),
                    child: Column(
                      children: [
                        // Avatar
                        _buildAvatar(),
                        const SizedBox(height: 12),

                        // Username & badges
                        _buildNameSection(),
                        const SizedBox(height: 8),

                        // Level & XP
                        Text(
                          'Seviye ${_profile!.currentLevel} • ${_profile!.totalXP} XP',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),

                        // Bio
                        if (_profile!.bio != null) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _profile!.bio!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Stats
                        _buildStatsRow(isDark),
                        const SizedBox(height: 20),

                        // Follow button
                        _buildFollowButton(),
                        const SizedBox(height: 24),

                        // Badges section
                        if (_profile!.badges.isNotEmpty) _buildBadgesSection(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFFFF6347).withOpacity(0.2),
        backgroundImage:
            _profile!.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
        child: _profile!.avatarUrl == null
            ? Text(
                _profile!.username.isNotEmpty ? _profile!.username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6347),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNameSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _profile!.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (_profile!.isPremium) ...[
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6347), // Theme color
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Tarifler', value: _profile!.totalRecipes.toString()),
          _StatItem(label: 'Favoriler', value: _profile!.totalFavorites.toString()),
          _StatItem(label: 'Takipçi', value: _profile!.followersCount.toString()),
          _StatItem(label: 'Takip', value: _profile!.followingCount.toString()),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? Colors.grey[300] : const Color(0xFFFF6347),
            foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _isFollowing ? 'Takipten Çık' : 'Takip Et',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rozetler (${_profile!.badges.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _profile!.badges.map((badge) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6347).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF6347).withOpacity(0.3)),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Color(0xFFFF6347), fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing) {
      await _social.unfollowUser(widget.userId);
    } else {
      await _social.followUser(widget.userId);
    }
    setState(() => _isFollowing = !_isFollowing);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
