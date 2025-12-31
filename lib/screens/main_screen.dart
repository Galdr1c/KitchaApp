import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'ai_assistant_screen.dart';
import '../providers/sync_provider.dart';
import '../services/firebase_mcp_service.dart';

/// Main screen with BottomNavigationBar for app navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AIAssistantScreen(),
    FavoritesScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize providers on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().initialize();
      context.read<AnalysisProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Kitcha' : 
          _currentIndex == 1 ? 'AI Asistan' :
          _currentIndex == 2 ? 'Favoriler' : 'Geçmiş',
        ),
        actions: [
          _buildSyncIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner at top
          const OfflineBanner(),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Asistan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
        ],
      ),
    );
  }
  Widget _buildSyncIndicator() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        if (!FirebaseMcpService().isAuthenticated) return const SizedBox.shrink();

        if (syncProvider.status == SyncStatus.syncing) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        }

        return IconButton(
          icon: Icon(
            syncProvider.status == SyncStatus.error ? Icons.sync_problem : Icons.sync,
            color: syncProvider.status == SyncStatus.error ? Colors.red : null,
          ),
          onPressed: syncProvider.syncNow,
          tooltip: 'Şimdi senkronize et',
        );
      },
    );
  }
}

