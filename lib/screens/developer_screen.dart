import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/mcp_manager_service.dart';
import '../models/mcp_server_config.dart';
import 'package:intl/intl.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geliştirici Seçenekleri'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dns), text: 'Sunucular'),
            Tab(icon: Icon(Icons.history), text: 'Loglar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServersTab(),
          _buildLogsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<McpManagerService>().testAllServers(),
        child: const Icon(Icons.refresh),
        tooltip: 'Tümünü Test Et',
      ),
    );
  }

  Widget _buildServersTab() {
    return Consumer<McpManagerService>(
      builder: (context, manager, _) {
        return ListView.builder(
          itemCount: manager.servers.length,
          itemBuilder: (context, index) {
            final server = manager.servers[index];
            return _buildServerCard(server, manager);
          },
        );
      },
    );
  }

  Widget _buildServerCard(McpServerConfig server, McpManagerService manager) {
    final stats = manager.getStats(server.name);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(server.status),
          radius: 10,
        ),
        title: Text(server.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(server.url, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          onPressed: () => manager.healthCheck(server),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Başarı Oranı', '${server.successRate.toStringAsFixed(1)}%'),
                _buildStatRow('Yanıt Süresi', '${server.lastResponseTimeMs}ms'),
                _buildStatRow('Toplam Çağrı', '${stats?.totalCalls ?? 0}'),
                const Divider(),
                const Text('Araçlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (server.availableTools != null)
                  ...server.availableTools!.map((tool) => ListTile(
                    dense: true,
                    title: Text(tool['name']),
                    subtitle: Text(tool['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.test_confirmation, size: 16),
                    onTap: () => _testTool(server, tool),
                  ))
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Henüz liste alınmadı', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Consumer<McpManagerService>(
      builder: (context, manager, _) {
        if (manager.logs.isEmpty) {
          return const Center(child: Text('Henüz log bulunmuyor'));
        }
        return ListView.builder(
          itemCount: manager.logs.length,
          itemBuilder: (context, index) {
            final log = manager.logs[index];
            return ListTile(
              dense: true,
              leading: Icon(
                log.isSuccess ? Icons.check_circle : Icons.error,
                color: log.isSuccess ? Colors.green : Colors.red,
              ),
              title: Text('${log.serverName} > ${log.toolName}'),
              subtitle: Text(DateFormat('HH:mm:ss').format(log.timestamp)),
              trailing: Text('${log.duration.inMilliseconds}ms'),
              onTap: () => _showLogDetail(log),
            );
          },
        );
      },
    );
  }

  void _showLogDetail(McpCallLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Detayı', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('Sunucu', log.serverName),
                    _buildStatRow('Araç', log.toolName),
                    _buildStatRow('Zaman', log.timestamp.toString()),
                    _buildStatRow('Süre', '${log.duration.inMilliseconds}ms'),
                    _buildStatRow('Sonuç', log.isSuccess ? 'Başarılı' : 'Hata'),
                    if (log.errorMessage != null)
                      Text('Hata Mesajı:\n${log.errorMessage}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    const Text('Parametreler:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildJsonView(log.parameters),
                    const SizedBox(height: 16),
                    const Text('Yanıt:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildJsonView(log.response),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonView(Map<String, dynamic>? data) {
    if (data == null) return const Text('N/A');
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: SelectableText(const JsonEncoder.withIndent('  ').convert(data), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
    );
  }

  void _testTool(McpServerConfig server, dynamic tool) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tool['name']} aracı test ediliyor... (Demo)')),
    );
  }

  Color _getStatusColor(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.active: return Colors.green;
      case McpServerStatus.inactive: return Colors.grey;
      case McpServerStatus.testing: return Colors.blue;
      case McpServerStatus.error: return Colors.red;
    }
  }
}
