import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../design_system/design_system.dart';
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
        title: const Text('Offline Management'),
        backgroundColor: ref.colors.surface,
        foregroundColor: ref.colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Animated Connection Status Indicator
          AnimatedBuilder(
            animation: AlwaysStoppedAnimation(0),
            builder: (context, child) {
              return connectivityStatus.when(
                data: (status) => TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: status.isConnected ? 0 : value * 0.1,
                      child: Container(
                        margin: const EdgeInsets.only(right: DSTokens.spaceM),
                        padding: const EdgeInsets.all(DSTokens.spaceS),
                        decoration: BoxDecoration(
                          color: status.isConnected
                              ? DSColors.success.withValues(alpha: 0.1)
                              : DSColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSTokens.radiusS),
                          border: Border.all(
                            color: status.isConnected
                                ? DSColors.success.withValues(alpha: 0.3)
                                : DSColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                status.isConnected
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                key: ValueKey(status.isConnected),
                                color: status.isConnected
                                    ? DSColors.success
                                    : DSColors.error,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: DSTokens.spaceXS),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: DSTypography.labelSmall.copyWith(
                                color: status.isConnected
                                    ? DSColors.success
                                    : DSColors.error,
                                fontWeight: DSTokens.fontWeightSemiBold,
                              ),
                              child: Text(
                                status.isConnected ? 'Online' : 'Offline',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => Container(
                  margin: const EdgeInsets.only(right: DSTokens.spaceM),
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ref.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: DSTokens.spaceXS),
                      Text(
                        'Checking...',
                        style: DSTypography.labelSmall.copyWith(
                          color: ref.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (_, _) => Container(
                  margin: const EdgeInsets.only(right: DSTokens.spaceM),
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: DSColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: DSTokens.spaceXS),
                      Text(
                        'Error',
                        style: DSTypography.labelSmall.copyWith(
                          color: DSColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header dengan Context
            Padding(
              padding: const EdgeInsets.only(bottom: DSTokens.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: DSTypography.displaySmall.copyWith(
                      color: ref.colors.textPrimary,
                      fontWeight: DSTokens.fontWeightBold,
                    ),
                  ),
                  const SizedBox(height: DSTokens.spaceXS),
                  Text(
                    'Monitor and manage offline capabilities',
                    style: DSTypography.bodyLarge.copyWith(
                      color: ref.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Smart Status Overview (menggabungkan Quick Stats + Current Status)
            _smartStatusOverview(
              connectivityStatus: connectivityStatus,
              pendingSyncCount: pendingSyncCount,
              canWorkOffline: canWorkOffline,
              ref: ref,
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

            // Progressive Disclosure: Advanced Settings
            _AdvancedSettingsSection(ref: ref),

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

  // Quick Stat Card Widget with Animation

  // Shimmer Loading Quick Stat

  // Enhanced Error State Tile with Recovery Actions

  // Smart Status Overview - Menggabungkan Quick Stats + Detailed Info
  Widget _smartStatusOverview({
    required AsyncValue connectivityStatus,
    required AsyncValue<int> pendingSyncCount,
    required AsyncValue<bool> canWorkOffline,
    required WidgetRef ref,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              decoration: BoxDecoration(
                color: ref.colors.surface,
                borderRadius: BorderRadius.circular(DSTokens.radiusXL),
                border: Border.all(color: ref.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: ref.colors.shadowColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan Overall System Health
                  Container(
                    padding: const EdgeInsets.all(DSTokens.spaceL),
                    decoration: BoxDecoration(
                      gradient: _getSystemHealthGradient(
                        connectivityStatus,
                        pendingSyncCount,
                        canWorkOffline,
                        ref,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(DSTokens.radiusXL),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildSystemHealthIndicator(
                          connectivityStatus: connectivityStatus,
                          pendingSyncCount: pendingSyncCount,
                          canWorkOffline: canWorkOffline,
                          ref: ref,
                        ),
                        const SizedBox(width: DSTokens.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getSystemHealthTitle(
                                  connectivityStatus,
                                  pendingSyncCount,
                                  canWorkOffline,
                                ),
                                style: DSTypography.headlineSmall.copyWith(
                                  color: DSColors.textOnColor,
                                  fontWeight: DSTokens.fontWeightBold,
                                ),
                              ),
                              const SizedBox(height: DSTokens.spaceXXS),
                              Text(
                                _getSystemHealthSubtitle(
                                  connectivityStatus,
                                  pendingSyncCount,
                                  canWorkOffline,
                                ),
                                style: DSTypography.bodyMedium.copyWith(
                                  color: DSColors.textOnColor.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick Action Button
                        _buildQuickActionButton(
                          connectivityStatus,
                          pendingSyncCount,
                          ref,
                          context,
                        ),
                      ],
                    ),
                  ),

                  // Detailed Metrics Grid
                  Padding(
                    padding: const EdgeInsets.all(DSTokens.spaceL),
                    child: Row(
                      children: [
                        // Connection Status
                        Expanded(
                          child: _buildSmartMetricCard(
                            title: 'Connection',
                            value: connectivityStatus.when(
                              data: (status) => _formatConnectionStatus(status),
                              loading: () => 'Checking...',
                              error: (_, _) => 'Error',
                            ),
                            icon: connectivityStatus.when(
                              data: (status) => _getConnectionIcon(status),
                              loading: () => Icons.refresh_rounded,
                              error: (_, _) => Icons.warning_rounded,
                            ),
                            color: connectivityStatus.when(
                              data: (status) => _getConnectionColor(status),
                              loading: () => ref.colors.textSecondary,
                              error: (_, _) => DSColors.error,
                            ),
                            isLoading: connectivityStatus.isLoading,
                            ref: ref,
                            onRetry: () =>
                                ref.invalidate(connectivityStatusProvider),
                          ),
                        ),

                        const SizedBox(width: DSTokens.spaceM),

                        // Sync Status
                        Expanded(
                          child: _buildSmartMetricCard(
                            title: 'Sync Queue',
                            value: pendingSyncCount.when(
                              data: (count) => '$count items',
                              loading: () => 'Loading...',
                              error: (_, _) => 'Error',
                            ),
                            icon: Icons.sync_rounded,
                            color: pendingSyncCount.when(
                              data: (count) => count > 0
                                  ? DSColors.warning
                                  : DSColors.success,
                              loading: () => ref.colors.textSecondary,
                              error: (_, _) => DSColors.error,
                            ),
                            isLoading: pendingSyncCount.isLoading,
                            ref: ref,
                            onRetry: () =>
                                ref.invalidate(pendingSyncCountProvider),
                          ),
                        ),

                        const SizedBox(width: DSTokens.spaceM),

                        // Offline Capability
                        Expanded(
                          child: _buildSmartMetricCard(
                            title: 'Offline Ready',
                            value: canWorkOffline.when(
                              data: (canWork) =>
                                  canWork ? 'Available' : 'Limited',
                              loading: () => 'Checking...',
                              error: (_, _) => 'Unknown',
                            ),
                            icon: Icons.cloud_off_rounded,
                            color: canWorkOffline.when(
                              data: (canWork) =>
                                  canWork ? DSColors.success : DSColors.warning,
                              loading: () => ref.colors.textSecondary,
                              error: (_, _) => DSColors.error,
                            ),
                            isLoading: canWorkOffline.isLoading,
                            ref: ref,
                            onRetry: () =>
                                ref.invalidate(canWorkOfflineProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods untuk Smart Status Overview
  Gradient _getSystemHealthGradient(
    AsyncValue connectivityStatus,
    AsyncValue<int> pendingSyncCount,
    AsyncValue<bool> canWorkOffline,
    WidgetRef ref,
  ) {
    // Menentukan overall system health berdasarkan semua metrik
    final isOnline =
        connectivityStatus.value == ConnectivityStatus.wifi ||
        connectivityStatus.value == ConnectivityStatus.mobile;
    final pendingCount = pendingSyncCount.value ?? 0;
    final canWork = canWorkOffline.value ?? false;

    if (isOnline && pendingCount == 0 && canWork) {
      // Excellent health
      return LinearGradient(
        colors: [DSColors.success, DSColors.success.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isOnline || canWork) {
      // Good health
      return LinearGradient(
        colors: [
          DSColors.brandPrimary,
          DSColors.brandPrimary.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Poor health
      return LinearGradient(
        colors: [DSColors.warning, DSColors.warning.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Widget _buildSystemHealthIndicator({
    required AsyncValue connectivityStatus,
    required AsyncValue<int> pendingSyncCount,
    required AsyncValue<bool> canWorkOffline,
    required WidgetRef ref,
  }) {
    final isOnline =
        connectivityStatus.value == ConnectivityStatus.wifi ||
        connectivityStatus.value == ConnectivityStatus.mobile;
    final pendingCount = pendingSyncCount.value ?? 0;
    final canWork = canWorkOffline.value ?? false;

    IconData icon;
    if (isOnline && pendingCount == 0 && canWork) {
      icon = Icons.check_circle_rounded;
    } else if (isOnline || canWork) {
      icon = Icons.info_rounded;
    } else {
      icon = Icons.warning_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: DSColors.textOnColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
      ),
      child: Icon(icon, color: DSColors.textOnColor, size: DSTokens.fontXXL),
    );
  }

  String _getSystemHealthTitle(
    AsyncValue connectivityStatus,
    AsyncValue<int> pendingSyncCount,
    AsyncValue<bool> canWorkOffline,
  ) {
    final isOnline =
        connectivityStatus.value == ConnectivityStatus.wifi ||
        connectivityStatus.value == ConnectivityStatus.mobile;
    final pendingCount = pendingSyncCount.value ?? 0;
    final canWork = canWorkOffline.value ?? false;

    if (isOnline && pendingCount == 0 && canWork) {
      return 'System Optimal';
    } else if (isOnline || canWork) {
      return 'System Ready';
    } else {
      return 'Limited Functionality';
    }
  }

  String _getSystemHealthSubtitle(
    AsyncValue connectivityStatus,
    AsyncValue<int> pendingSyncCount,
    AsyncValue<bool> canWorkOffline,
  ) {
    final isOnline =
        connectivityStatus.value == ConnectivityStatus.wifi ||
        connectivityStatus.value == ConnectivityStatus.mobile;
    final pendingCount = pendingSyncCount.value ?? 0;
    final canWork = canWorkOffline.value ?? false;

    if (isOnline && pendingCount == 0 && canWork) {
      return 'All systems running smoothly';
    } else if (isOnline) {
      return pendingCount > 0
          ? '$pendingCount items pending sync'
          : 'Connected and ready';
    } else if (canWork) {
      return 'Offline mode available';
    } else {
      return 'Connection required for full features';
    }
  }

  Widget _buildQuickActionButton(
    AsyncValue connectivityStatus,
    AsyncValue<int> pendingSyncCount,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isOnline =
        connectivityStatus.value == ConnectivityStatus.wifi ||
        connectivityStatus.value == ConnectivityStatus.mobile;
    final pendingCount = pendingSyncCount.value ?? 0;

    String label;
    VoidCallback? onPressed;
    IconData icon;

    if (isOnline && pendingCount > 0) {
      label = 'Sync Now';
      icon = Icons.sync_rounded;
      onPressed = () async {
        try {
          await ref.read(offlineSyncServiceProvider).forcSync();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sync completed')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
          }
        }
      };
    } else if (!isOnline) {
      label = 'Retry';
      icon = Icons.refresh_rounded;
      onPressed = () {
        // Force refresh providers
        ref.invalidate(connectivityStatusProvider);
        ref.invalidate(pendingSyncCountProvider);
        ref.invalidate(canWorkOfflineProvider);
      };
    } else {
      label = 'Refresh';
      icon = Icons.refresh_rounded;
      onPressed = () {
        // Force refresh providers
        ref.invalidate(connectivityStatusProvider);
        ref.invalidate(pendingSyncCountProvider);
        ref.invalidate(canWorkOfflineProvider);
      };
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: DSColors.textOnColor.withValues(alpha: 0.2),
        foregroundColor: DSColors.textOnColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: DSTokens.spaceM,
          vertical: DSTokens.spaceS,
        ),
      ),
    );
  }

  Widget _buildSmartMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required WidgetRef ref,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: DSTokens.fontL),
              const Spacer(),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else if (onRetry != null)
                GestureDetector(
                  onTap: onRetry,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: ref.colors.textSecondary,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSTokens.spaceS),
          Text(
            title,
            style: DSTypography.bodySmall.copyWith(
              color: ref.colors.textSecondary,
              fontWeight: DSTokens.fontWeightMedium,
            ),
          ),
          const SizedBox(height: DSTokens.spaceXXS),
          Text(
            value,
            style: DSTypography.bodyLarge.copyWith(
              color: color,
              fontWeight: DSTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods untuk connection formatting
  String _formatConnectionStatus(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile';
      case ConnectivityStatus.none:
        return 'Offline';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
    }
  }

  IconData _getConnectionIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.wifi:
        return Icons.wifi_rounded;
      case ConnectivityStatus.mobile:
        return Icons.signal_cellular_alt_rounded;
      case ConnectivityStatus.ethernet:
        return Icons.router_rounded;
      case ConnectivityStatus.none:
        return Icons.wifi_off_rounded;
    }
  }

  Color _getConnectionColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.wifi:
      case ConnectivityStatus.mobile:
      case ConnectivityStatus.ethernet:
        return DSColors.success;
      case ConnectivityStatus.none:
        return DSColors.error;
    }
  }
}

// Expandable Advanced Settings Section
class _AdvancedSettingsSection extends StatefulWidget {
  final WidgetRef ref;

  const _AdvancedSettingsSection({required this.ref});

  @override
  State<_AdvancedSettingsSection> createState() =>
      _AdvancedSettingsSectionState();
}

class _AdvancedSettingsSectionState extends State<_AdvancedSettingsSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
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
                  // Header with expand/collapse
                  Semantics(
                    label: 'Advanced Settings',
                    hint: _isExpanded
                        ? 'Expanded. Tap to collapse advanced settings'
                        : 'Collapsed. Tap to expand advanced settings',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleExpansion,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(DSTokens.radiusL),
                          bottom: _isExpanded
                              ? Radius.zero
                              : Radius.circular(DSTokens.radiusL),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(DSTokens.spaceL),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(DSTokens.spaceS),
                                decoration: BoxDecoration(
                                  color: DSColors.brandSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.radiusM,
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: DSColors.brandSecondary,
                                  size: DSTokens.fontL,
                                ),
                              ),
                              const SizedBox(width: DSTokens.spaceM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Advanced Settings',
                                      style: DSTypography.headlineSmall
                                          .copyWith(
                                            color: ref.colors.textPrimary,
                                            fontWeight: DSTokens.fontWeightBold,
                                          ),
                                    ),
                                    const SizedBox(height: DSTokens.spaceXXS),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style: DSTypography.bodySmall.copyWith(
                                        color: ref.colors.textSecondary,
                                      ),
                                      child: Text(
                                        _isExpanded
                                            ? 'Configure advanced offline behavior'
                                            : 'Tap to configure advanced options',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Animated Arrow
                              AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value * 3.14159,
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: ref.colors.textSecondary,
                                      size: DSTokens.fontL,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Expandable Content
                  AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: _expandAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        DSTokens.spaceL,
                        0,
                        DSTokens.spaceL,
                        DSTokens.spaceL,
                      ),
                      child: Column(
                        children: [
                          // Divider
                          Container(
                            height: 1,
                            color: ref.colors.border,
                            margin: const EdgeInsets.only(
                              bottom: DSTokens.spaceL,
                            ),
                          ),

                          // Advanced Settings Options
                          _buildAdvancedOption(
                            ref: ref,
                            icon: Icons.sync_alt_rounded,
                            title: 'Auto-sync Interval',
                            description:
                                'How often to sync when connection is available',
                            value: '5 minutes',
                            onTap: () => _showSyncIntervalDialog(ref),
                          ),

                          _buildAdvancedOption(
                            ref: ref,
                            icon: Icons.storage_rounded,
                            title: 'Cache Size Limit',
                            description: 'Maximum storage for offline data',
                            value: '100 MB',
                            onTap: () => _showCacheLimitDialog(ref),
                          ),

                          _buildAdvancedOption(
                            ref: ref,
                            icon: Icons.battery_saver_rounded,
                            title: 'Battery Optimization',
                            description: 'Reduce sync frequency on low battery',
                            value: 'Enabled',
                            onTap: () => _showBatteryOptimizationDialog(ref),
                          ),

                          _buildAdvancedOption(
                            ref: ref,
                            icon: Icons.network_check_rounded,
                            title: 'Network Requirements',
                            description: 'When to perform sync operations',
                            value: 'WiFi Only',
                            onTap: () => _showNetworkRequirementsDialog(ref),
                          ),

                          _buildAdvancedOption(
                            ref: ref,
                            icon: Icons.history_rounded,
                            title: 'Sync History',
                            description: 'View recent sync operations',
                            value: 'View',
                            onTap: () => _showSyncHistory(ref),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedOption({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title: $value',
      hint: description,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          child: Container(
            padding: const EdgeInsets.all(DSTokens.spaceM),
            margin: const EdgeInsets.only(bottom: DSTokens.spaceS),
            decoration: BoxDecoration(
              color: ref.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              border: Border.all(
                color: ref.colors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  decoration: BoxDecoration(
                    color: DSColors.brandSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: DSColors.brandSecondary,
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
                      const SizedBox(height: DSTokens.spaceXXS),
                      Text(
                        description,
                        style: DSTypography.bodySmall.copyWith(
                          color: ref.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSTokens.spaceS,
                    vertical: DSTokens.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusS),
                  ),
                  child: Text(
                    value,
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.brandPrimary,
                      fontWeight: DSTokens.fontWeightSemiBold,
                    ),
                  ),
                ),
                const SizedBox(width: DSTokens.spaceS),
                Icon(
                  Icons.chevron_right_rounded,
                  color: ref.colors.textSecondary,
                  size: DSTokens.fontM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Placeholder dialog methods
  void _showSyncIntervalDialog(WidgetRef ref) {
    // TODO: Implement sync interval configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync interval configuration coming soon')),
    );
  }

  void _showCacheLimitDialog(WidgetRef ref) {
    // TODO: Implement cache limit configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache limit configuration coming soon')),
    );
  }

  void _showBatteryOptimizationDialog(WidgetRef ref) {
    // TODO: Implement battery optimization configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Battery optimization configuration coming soon'),
      ),
    );
  }

  void _showNetworkRequirementsDialog(WidgetRef ref) {
    // TODO: Implement network requirements configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Network requirements configuration coming soon'),
      ),
    );
  }

  void _showSyncHistory(WidgetRef ref) {
    // TODO: Implement sync history view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync history view coming soon')),
    );
  }
}
