import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Screen for managing notification settings.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _service = NotificationService();
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    _prefs = await _service.getPreferences();
    setState(() => _isLoading = false);
  }

  Future<void> _savePreferences() async {
    await _service.savePreferences(_prefs);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection(
                  isDark,
                  title: 'Hatırlatmalar',
                  children: [
                    _buildSwitch(
                      title: 'Günlük Hatırlatma',
                      subtitle: 'Her gün tarif önerileri al',
                      value: _prefs.dailyReminder,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(dailyReminder: v));
                        _savePreferences();
                      },
                    ),
                    if (_prefs.dailyReminder)
                      _buildTimeSelector(isDark),
                    _buildSwitch(
                      title: 'Öğün Hatırlatması',
                      subtitle: 'Planlanan öğünler için hatırlatma',
                      value: _prefs.mealReminder,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(mealReminder: v));
                        _savePreferences();
                      },
                    ),
                  ],
                ),
                _buildSection(
                  isDark,
                  title: 'Sosyal',
                  children: [
                    _buildSwitch(
                      title: 'Challenge Güncellemeleri',
                      subtitle: 'Haftalık challenge bildirimleri',
                      value: _prefs.challengeUpdates,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(challengeUpdates: v));
                        _savePreferences();
                      },
                    ),
                    _buildSwitch(
                      title: 'Haftalık Özet',
                      subtitle: 'Haftalık aktivite özeti',
                      value: _prefs.weeklyDigest,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(weeklyDigest: v));
                        _savePreferences();
                      },
                    ),
                  ],
                ),
                _buildSection(
                  isDark,
                  title: 'Diğer',
                  children: [
                    _buildSwitch(
                      title: 'Yeni Tarifler',
                      subtitle: 'Yeni tarif önerileri',
                      value: _prefs.newRecipes,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(newRecipes: v));
                        _savePreferences();
                      },
                    ),
                    _buildSwitch(
                      title: 'Promosyonlar',
                      subtitle: 'İndirim ve kampanya bildirimleri',
                      value: _prefs.promotions,
                      onChanged: (v) {
                        setState(() => _prefs = _prefs.copyWith(promotions: v));
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection(bool isDark, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Container(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFF6347),
    );
  }

  Widget _buildTimeSelector(bool isDark) {
    return ListTile(
      title: const Text('Hatırlatma Saati'),
      subtitle: Text(_prefs.dailyReminderTime),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final parts = _prefs.dailyReminderTime.split(':');
        final initial = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        final selected = await showTimePicker(
          context: context,
          initialTime: initial,
        );

        if (selected != null) {
          final time = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
          setState(() => _prefs = _prefs.copyWith(dailyReminderTime: time));
          _savePreferences();
        }
      },
    );
  }
}
