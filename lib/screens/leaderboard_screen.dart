import 'package:flutter/material.dart' hide Badge;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

/// Leaderboard screen showing XP rankings.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sıralama 🏆'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Tüm Zamanlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboard('weekly'),
          _buildLeaderboard('monthly'),
          _buildLeaderboard('allTime'),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(String period) {
    if (!FirebaseService.isAvailable) {
      return _buildMockLeaderboard();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('gamification.totalXP', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildMockLeaderboard();
        }

        final users = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return Column(
          children: [
            if (users.length >= 3) _buildPodium(users.take(3).toList()),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length > 3 ? users.length - 3 : 0,
                itemBuilder: (context, index) {
                  final rank = index + 4;
                  final userDoc = users[index + 3];
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final isCurrentUser = userDoc.id == currentUserId;
                  final gamification = userData['gamification'] as Map<String, dynamic>? ?? {};

                  return _buildLeaderboardItem(
                    rank: rank,
                    userName: userData['displayName'] ?? 'Anonim',
                    xp: gamification['totalXP'] ?? 0,
                    level: gamification['level'] ?? 1,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMockLeaderboard() {
    final mockUsers = [
      {'name': 'MasterChef_Ahmet', 'xp': 2450, 'level': 6},
      {'name': 'Mutfak_Sihirbazı', 'xp': 1890, 'level': 5},
      {'name': 'GurmeAyşe', 'xp': 1650, 'level': 5},
      {'name': 'LezzetUstası', 'xp': 1420, 'level': 4},
      {'name': 'YemekTutkunuMehmet', 'xp': 1180, 'level': 4},
      {'name': 'Aşçı_Zeynep', 'xp': 950, 'level': 3},
      {'name': 'TarifciAli', 'xp': 780, 'level': 3},
      {'name': 'MutfakPensesi', 'xp': 620, 'level': 2},
    ];

    return Column(
      children: [
        _buildMockPodium(mockUsers.take(3).toList()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockUsers.length - 3,
            itemBuilder: (context, index) {
              final user = mockUsers[index + 3];
              return _buildLeaderboardItem(
                rank: index + 4,
                userName: user['name'] as String,
                xp: user['xp'] as int,
                level: user['level'] as int,
                isCurrentUser: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> users) {
    final getData = (int index) {
      final data = users[index].data() as Map<String, dynamic>;
      final gam = data['gamification'] as Map<String, dynamic>? ?? {};
      return {
        'name': data['displayName'] ?? 'Anonim',
        'xp': gam['totalXP'] ?? 0,
      };
    };

    return _buildPodiumUI(
      first: getData(0),
      second: getData(1),
      third: getData(2),
    );
  }

  Widget _buildMockPodium(List<Map<String, Object>> users) {
    return _buildPodiumUI(
      first: {'name': users[0]['name'], 'xp': users[0]['xp']},
      second: {'name': users[1]['name'], 'xp': users[1]['xp']},
      third: {'name': users[2]['name'], 'xp': users[2]['xp']},
    );
  }

  Widget _buildPodiumUI({
    required Map<String, dynamic> first,
    required Map<String, dynamic> second,
    required Map<String, dynamic> third,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumPlace(
            rank: 2,
            userName: second['name'] as String,
            xp: second['xp'] as int,
            height: 100,
            color: Colors.grey[400]!,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildPodiumPlace(
            rank: 1,
            userName: first['name'] as String,
            xp: first['xp'] as int,
            height: 130,
            color: const Color(0xFFFFD700),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildPodiumPlace(
            rank: 3,
            userName: third['name'] as String,
            xp: third['xp'] as int,
            height: 80,
            color: const Color(0xFFCD7F32),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace({
    required int rank,
    required String userName,
    required int xp,
    required double height,
    required Color color,
    required bool isDark,
  }) {
    final medals = ['🥇', '🥈', '🥉'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medals[rank - 1], style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$xp XP',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String userName,
    required int xp,
    required int level,
    required bool isCurrentUser,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFFFF6347).withOpacity(0.1)
            : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFFFF6347) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? const Color(0xFFFF6347) : null,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFF6347).withOpacity(0.2),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6347),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Seviye $level',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6347),
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
