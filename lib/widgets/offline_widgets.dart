import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

/// Banner showing offline status.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectivityStream,
      initialData: ConnectivityService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 32,
          color: Colors.orange,
          child: isOnline
              ? const SizedBox.shrink()
              : const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Çevrimdışı mod',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

/// Wrapper that shows sync status and handles offline mode.
class NetworkAwareWrapper extends StatefulWidget {
  final Widget child;
  final bool showOfflineBanner;

  const NetworkAwareWrapper({
    super.key,
    required this.child,
    this.showOfflineBanner = true,
  });

  @override
  State<NetworkAwareWrapper> createState() => _NetworkAwareWrapperState();
}

class _NetworkAwareWrapperState extends State<NetworkAwareWrapper> {
  final _connectivityService = ConnectivityService();
  final _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _connectivityService.connectivityStream.listen(_onConnectivityChange);
  }

  void _onConnectivityChange(bool isOnline) {
    if (isOnline) {
      // Auto-sync when coming online
      _syncService.syncNow().then((result) {
        if (result.synced > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.synced} öğe senkronize edildi'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showOfflineBanner) const OfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Sync status indicator widget.
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: SyncService().getPendingCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$pendingCount bekliyor',
                style: const TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Button to manually trigger sync.
class SyncButton extends StatefulWidget {
  const SyncButton({super.key});

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isSyncing ? null : _sync,
      icon: _isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      tooltip: 'Senkronize et',
    );
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);

    try {
      final result = await SyncService().syncNow();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isComplete
                  ? 'Senkronizasyon tamamlandı'
                  : '${result.synced} senkronize, ${result.remaining} bekliyor',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
