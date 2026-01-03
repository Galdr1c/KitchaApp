import 'package:flutter/material.dart';
import '../services/data_deletion_service.dart';
import '../services/data_export_service.dart';
import '../services/backup_service.dart';

/// Screen for privacy settings and GDPR compliance.
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isExporting = false;
  bool _isBackingUp = false;
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    final date = await BackupService().getLastBackupDate();
    setState(() => _lastBackupDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik & Veriler'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Verileriniz', isDark),
          _buildTile(
            icon: Icons.download,
            title: 'Verilerimi İndir',
            subtitle: 'Tüm verilerinizi JSON formatında indirin',
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _exportData,
          ),
          _buildTile(
            icon: Icons.cloud_upload,
            title: 'Yedekle',
            subtitle: _lastBackupDate != null
                ? 'Son yedek: ${_formatDate(_lastBackupDate!)}'
                : 'Henüz yedeklenmedi',
            trailing: _isBackingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _backupData,
          ),
          _buildTile(
            icon: Icons.cloud_download,
            title: 'Yedekten Geri Yükle',
            subtitle: 'Son yedeğinizi geri yükleyin',
            onTap: _restoreData,
          ),

          _buildSectionHeader('Hesap', isDark),
          _buildTile(
            icon: Icons.delete_forever,
            title: 'Hesabımı Sil',
            subtitle: 'Tüm verileriniz kalıcı olarak silinir',
            textColor: Colors.red,
            onTap: _deleteAccount,
          ),

          _buildSectionHeader('Gizlilik', isDark),
          _buildTile(
            icon: Icons.analytics_outlined,
            title: 'Analitik Paylaşımı',
            subtitle: 'Anonim kullanım verileri',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: const Color(0xFFFF6347),
            ),
            onTap: null,
          ),
          _buildTile(
            icon: Icons.bug_report,
            title: 'Hata Raporları',
            subtitle: 'Otomatik hata raporlama',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: const Color(0xFFFF6347),
            ),
            onTap: null,
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'GDPR ve KVKK kapsamında verilerinizi istediğiniz zaman indirebilir veya silebilirsiniz.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? const Color(0xFFFF6347)),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final path = await DataExportService().getExportFilePath();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler kaydedildi: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  Future<void> _backupData() async {
    setState(() => _isBackingUp = true);
    try {
      await BackupService().backupToCloud();
      await _loadBackupInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedekleme tamamlandı ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
    setState(() => _isBackingUp = false);
  }

  Future<void> _restoreData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geri Yükle'),
        content: const Text('Mevcut veriler yedeğinizle değiştirilecek. Devam edilsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BackupService().restoreFromCloud();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Geri yükleme tamamlandı ✓')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Tüm verileriniz kalıcı olarak silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DataDeletionService().deleteAllUserData();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
