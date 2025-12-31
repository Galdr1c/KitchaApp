import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_mcp_service.dart';
import '../providers/sync_provider.dart';
import '../services/memory_mcp_service.dart';
import '../services/notification_mcp_service.dart';
import '../models/notification_config.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseMcpService _firebaseMcp = FirebaseMcpService();
  final MemoryMcpService _memoryMcp = MemoryMcpService();
  final NotificationMcpService _notificationMcp = NotificationMcpService();
  int _developerTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildPremiumCard(
            title: 'Hesap Yönetimi',
            icon: Icons.person_outline,
            accentColor: Colors.blue,
            children: [_buildAccountSection()],
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: 'Senkronizasyon',
            icon: Icons.sync,
            accentColor: Colors.green,
            children: [_buildSyncSection()],
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: 'AI Hafıza & Kişiselleştirme',
            icon: Icons.auto_awesome,
            accentColor: AppTheme.accentAI,
            children: [_buildMemorySection()],
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: 'Bildirim Ayarları',
            icon: Icons.notifications_none,
            accentColor: Colors.orange,
            children: [_buildNotificationSection()],
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: 'Gizlilik ve Veri',
            icon: Icons.security,
            accentColor: Colors.red,
            children: [_buildPrivacySection()],
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: 'Uygulama',
            icon: Icons.info_outline,
            accentColor: Colors.grey,
            children: [_buildAppSection()],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = _firebaseMcp.currentUser;
    final isAuthenticated = _firebaseMcp.isAuthenticated;

    if (isAuthenticated) {
      return ListTile(
        title: Text(user!.email ?? 'Anonim Kullanıcı', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('ID: ${user.uid.substring(0, 8)}...', style: const TextStyle(fontSize: 12)),
        trailing: TextButton(
          onPressed: () async {
            await _firebaseMcp.signOut();
            setState(() {});
          },
          child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return ListTile(
        title: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: const Text('Bulut yedekleme için giriş yapın'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/login'),
      );
    }
  }

  Widget _buildSyncSection() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        final lastSync = syncProvider.lastSyncTime != null
            ? DateFormat('dd MMM, HH:mm', 'tr_TR').format(syncProvider.lastSyncTime!)
            : 'Henüz yapılmadı';

        return Column(
          children: [
            SwitchListTile(
              title: const Text('Otomatik Senkronizasyon', style: TextStyle(fontSize: 14)),
              value: syncProvider.autoSync,
              onChanged: syncProvider.setAutoSync,
              activeColor: AppTheme.primaryColor,
            ),
            ListTile(
              title: const Text('Son Senkronizasyon', style: TextStyle(fontSize: 14)),
              subtitle: Text(lastSync, style: const TextStyle(fontSize: 12)),
              trailing: syncProvider.status == SyncStatus.syncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.sync, color: AppTheme.primaryColor),
                      onPressed: syncProvider.syncNow,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemorySection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('AI Öğrenme Modu', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Yemek tercihlerinizden öğrenmeye devam et', style: TextStyle(fontSize: 12)),
          value: _memoryMcp.isLearningEnabled,
          onChanged: (value) async {
            await _memoryMcp.setLearningEnabled(value);
            setState(() {});
          },
          activeColor: AppTheme.accentAI,
        ),
        ListTile(
          title: const Text('Tercihlerimi Görüntüle', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Kitcha senin hakkında neler biliyor?', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () async {
            final contextStr = await _memoryMcp.searchContext('en sevdiğim yemekler');
            if (mounted) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Hafızası', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(contextStr, style: const TextStyle(height: 1.5)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final prefs = _notificationMcp.preferences;
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Öğün Önerileri', style: TextStyle(fontSize: 14)),
          value: prefs.mealSuggestionsEnabled,
          onChanged: (value) async {
            prefs.mealSuggestionsEnabled = value;
            await _notificationMcp.savePreferences(prefs);
            setState(() {});
          },
          activeColor: Colors.orange,
        ),
        SwitchListTile(
          title: const Text('Haftalık Özet', style: TextStyle(fontSize: 14)),
          value: prefs.goalTrackingEnabled,
          onChanged: (value) async {
            prefs.goalTrackingEnabled = value;
            await _notificationMcp.savePreferences(prefs);
            setState(() {});
          },
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Verilerimi Dışa Aktar', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Tüm verilerini JSON formatında indir', style: TextStyle(fontSize: 12)),
          leading: const Icon(Icons.download_outlined, size: 20),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veriler hazırlanıyor...'))),
        ),
        ListTile(
          title: const Text('Hafızayı ve Verileri Sil', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Öğrenilen tercihleri ve geçmişi temizle', style: TextStyle(fontSize: 12)),
          leading: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onTap: () => _confirmClearMemory(),
        ),
      ],
    );
  }

  void _confirmClearMemory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hafızayı Sil?'),
        content: const Text('Tüm öğrenilen verileriniz silinecek. Kitcha size özel öneriler sunamayabilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () async {
              await _memoryMcp.clearMemory();
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI hafızası temizlendi')));
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Hakkında', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Kitcha AI v1.2.0 (MCP Early Access)', style: TextStyle(fontSize: 12)),
          onTap: () {
            _developerTapCount++;
            if (_developerTapCount >= 7) {
              _developerTapCount = 0;
              _showDeveloperPasswordDialog();
            }
          },
        ),
      ],
    );
  }

  void _showDeveloperPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geliştirici Girişi'),
        content: TextField(controller: controller, obscureText: true, decoration: const InputDecoration(labelText: 'Şifre'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              if (controller.text == 'kitcha2024') {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/developer');
              }
            },
            child: const Text('Giriş'),
          ),
        ],
      ),
    );
  }
}
