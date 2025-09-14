import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../design_system/design_system.dart';
import '../../../design_system/utils/theme_colors.dart';
import '../../widgets/connectivity/offline_status_indicator.dart';
import '../../providers/offline_auth_provider_new.dart';

/// Screen to demonstrate and manage offline functionality
class OfflineDemoScreen extends ConsumerWidget {
  const OfflineDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final pendingSyncCount = ref.watch(pendingSyncCountProvider);
    final canWorkOffline = ref.watch(canWorkOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode Demo'),
        backgroundColor: ref.colors.surface,
        foregroundColor: ref.colors.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Section
            _buildSectionCard(
              context: context,
              ref: ref,
              title: 'Current Status',
              icon: Icons.signal_wifi_statusbar_null_rounded,
              child: Column(
                children: [
                  const OfflineStatusIndicator(showDetails: true),
                  const SizedBox(height: DSTokens.spaceM),

                  // Connectivity Status
                  connectivityStatus.when(
                    data: (status) => _buildStatusTile(
                      ref: ref,
                      icon: status.isConnected
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      title: 'Connection',
                      subtitle: status.displayName,
                      isPositive: status.isConnected,
                    ),
                    loading: () => _buildStatusTile(
                      ref: ref,
                      icon: Icons.refresh_rounded,
                      title: 'Connection',
                      subtitle: 'Checking...',
                      isPositive: null,
                    ),
                    error: (_, __) => _buildStatusTile(
                      ref: ref,
                      icon: Icons.error_rounded,
                      title: 'Connection',
                      subtitle: 'Error checking status',
                      isPositive: false,
                    ),
                  ),

                  const SizedBox(height: DSTokens.spaceS),

                  // Pending Sync Count
                  pendingSyncCount.when(
                    data: (count) => _buildStatusTile(
                      ref: ref,
                      icon: count > 0
                          ? Icons.sync_problem_rounded
                          : Icons.sync_rounded,
                      title: 'Pending Sync',
                      subtitle: count > 0
                          ? '$count operation${count == 1 ? '' : 's'} pending'
                          : 'All synced',
                      isPositive: count == 0,
                    ),
                    loading: () => _buildStatusTile(
                      ref: ref,
                      icon: Icons.refresh_rounded,
                      title: 'Pending Sync',
                      subtitle: 'Checking...',
                      isPositive: null,
                    ),
                    error: (_, __) => _buildStatusTile(
                      ref: ref,
                      icon: Icons.error_rounded,
                      title: 'Pending Sync',
                      subtitle: 'Error checking status',
                      isPositive: false,
                    ),
                  ),

                  const SizedBox(height: DSTokens.spaceS),

                  // Offline Capability
                  canWorkOffline.when(
                    data: (canWork) => _buildStatusTile(
                      ref: ref,
                      icon: canWork
                          ? Icons.offline_bolt_rounded
                          : Icons.cloud_off_rounded,
                      title: 'Offline Mode',
                      subtitle: canWork
                          ? 'Ready to work offline'
                          : 'No cached data available',
                      isPositive: canWork,
                    ),
                    loading: () => _buildStatusTile(
                      ref: ref,
                      icon: Icons.refresh_rounded,
                      title: 'Offline Mode',
                      subtitle: 'Checking...',
                      isPositive: null,
                    ),
                    error: (_, __) => _buildStatusTile(
                      ref: ref,
                      icon: Icons.error_rounded,
                      title: 'Offline Mode',
                      subtitle: 'Error checking status',
                      isPositive: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSTokens.spaceL),

            // Features Section
            _buildSectionCard(
              context: context,
              ref: ref,
              title: 'Offline Features',
              icon: Icons.offline_bolt_rounded,
              child: Column(
                children: [
                  _buildFeatureTile(
                    ref: ref,
                    icon: Icons.cached_rounded,
                    title: 'Local Data Cache',
                    description:
                        'User profiles and data are cached locally for offline access',
                    isEnabled: true,
                  ),

                  _buildFeatureTile(
                    ref: ref,
                    icon: Icons.sync_rounded,
                    title: 'Auto Sync',
                    description:
                        'Changes sync automatically when connection is restored',
                    isEnabled: true,
                  ),

                  _buildFeatureTile(
                    ref: ref,
                    icon: Icons.queue_rounded,
                    title: 'Operation Queue',
                    description:
                        'Operations are queued and executed when online',
                    isEnabled: true,
                  ),

                  _buildFeatureTile(
                    ref: ref,
                    icon: Icons.person_rounded,
                    title: 'Offline Authentication',
                    description: 'Continue working with cached user session',
                    isEnabled: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSTokens.spaceL),

            // Actions Section
            _buildSectionCard(
              context: context,
              ref: ref,
              title: 'Actions',
              icon: Icons.settings_rounded,
              child: Column(
                children: [
                  _buildActionButton(
                    context: context,
                    ref: ref,
                    icon: Icons.sync_rounded,
                    title: 'Force Sync Now',
                    subtitle: 'Sync all pending operations',
                    onTap: () => _forceSyncTapped(ref, context),
                    isEnabled: connectivityStatus.value?.isConnected == true,
                  ),

                  const SizedBox(height: DSTokens.spaceM),

                  _buildActionButton(
                    context: context,
                    ref: ref,
                    icon: Icons.clear_all_rounded,
                    title: 'Clear Offline Data',
                    subtitle: 'Remove all cached data',
                    onTap: () => _clearOfflineDataTapped(ref, context),
                    isEnabled: true,
                    isDangerous: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSTokens.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(color: ref.colors.border),
        boxShadow: [
          BoxShadow(
            color: ref.colors.shadowColor.withValues(alpha: 0.1),
            blurRadius: DSTokens.spaceS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DSTokens.spaceL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  decoration: BoxDecoration(
                    color: DSColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: DSColors.brandPrimary,
                    size: DSTokens.fontL,
                  ),
                ),
                const SizedBox(width: DSTokens.spaceM),
                Text(
                  title,
                  style: DSTypography.headlineSmall.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: DSTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSTokens.spaceL,
              0,
              DSTokens.spaceL,
              DSTokens.spaceL,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool? isPositive,
  }) {
    final Color color = isPositive == null
        ? ref.colors.textSecondary
        : isPositive
        ? DSColors.success
        : DSColors.error;

    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: DSTokens.fontL),
          const SizedBox(width: DSTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.labelLarge.copyWith(
                    color: color,
                    fontWeight: DSTokens.fontWeightSemiBold,
                  ),
                ),
                Text(
                  subtitle,
                  style: DSTypography.bodySmall.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSTokens.spaceM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSTokens.spaceS),
            decoration: BoxDecoration(
              color: isEnabled
                  ? DSColors.success.withValues(alpha: 0.1)
                  : DSColors.neutral300.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSTokens.radiusS),
            ),
            child: Icon(
              icon,
              color: isEnabled ? DSColors.success : DSColors.neutral300,
              size: DSTokens.fontM,
            ),
          ),
          const SizedBox(width: DSTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.bodyLarge.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: DSTokens.fontWeightSemiBold,
                  ),
                ),
                Text(
                  description,
                  style: DSTypography.bodySmall.copyWith(
                    color: ref.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isEnabled,
    bool isDangerous = false,
  }) {
    final color = isDangerous ? DSColors.error : DSColors.brandPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        child: Container(
          padding: const EdgeInsets.all(DSTokens.spaceM),
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withValues(alpha: 0.1)
                : ref.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(DSTokens.radiusM),
            border: Border.all(
              color: isEnabled
                  ? color.withValues(alpha: 0.3)
                  : ref.colors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isEnabled ? color : ref.colors.textTertiary,
                size: DSTokens.fontL,
              ),
              const SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DSTypography.bodyLarge.copyWith(
                        color: isEnabled
                            ? ref.colors.textPrimary
                            : ref.colors.textTertiary,
                        fontWeight: DSTokens.fontWeightSemiBold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: DSTypography.bodySmall.copyWith(
                        color: isEnabled
                            ? ref.colors.textSecondary
                            : ref.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isEnabled
                    ? ref.colors.textSecondary
                    : ref.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _forceSyncTapped(WidgetRef ref, BuildContext context) async {
    final syncService = ref.read(offlineSyncServiceProvider);

    try {
      final result = await syncService.forcSync();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isSuccess
                ? DSColors.success
                : DSColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: DSColors.error,
          ),
        );
      }
    }
  }

  void _clearOfflineDataTapped(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Offline Data'),
        content: const Text(
          'This will remove all cached data. You will need to be online to use the app after this action. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final syncService = ref.read(offlineSyncServiceProvider);
              await syncService.clearOfflineData();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offline data cleared'),
                    backgroundColor: DSColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DSColors.error,
              foregroundColor: DSColors.textOnColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
