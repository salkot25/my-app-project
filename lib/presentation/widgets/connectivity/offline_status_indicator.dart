import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../design_system/design_system.dart';
import '../../../design_system/utils/theme_colors.dart';

/// Widget that displays current connectivity status and offline sync information
class OfflineStatusIndicator extends ConsumerWidget {
  final bool showDetails;
  final EdgeInsets? padding;

  const OfflineStatusIndicator({
    super.key,
    this.showDetails = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final pendingSyncCount = ref.watch(pendingSyncCountProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return connectivityStatus.when(
      data: (status) => _buildStatusIndicator(
        context,
        ref,
        status,
        pendingSyncCount,
        syncStatus,
      ),
      loading: () =>
          showDetails ? _buildLoadingIndicator(ref) : const SizedBox.shrink(),
      error: (_, __) =>
          showDetails ? _buildErrorIndicator(ref) : const SizedBox.shrink(),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    WidgetRef ref,
    ConnectivityStatus status,
    AsyncValue<int> pendingSyncCount,
    SyncResult? syncStatus,
  ) {
    final isConnected = status.isConnected;

    if (!showDetails && isConnected) {
      // Don't show indicator when online and details are not requested
      return const SizedBox.shrink();
    }

    final pendingCount = pendingSyncCount.value ?? 0;

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: DSTokens.spaceM,
            vertical: DSTokens.spaceS,
          ),
      margin: const EdgeInsets.all(DSTokens.spaceS),
      decoration: BoxDecoration(
        color: _getStatusColor(
          status,
          pendingCount,
          ref,
        ).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(
          color: _getStatusColor(
            status,
            pendingCount,
            ref,
          ).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: showDetails
          ? _buildDetailedStatus(context, ref, status, pendingCount, syncStatus)
          : _buildCompactStatus(ref, status, pendingCount),
    );
  }

  Widget _buildDetailedStatus(
    BuildContext context,
    WidgetRef ref,
    ConnectivityStatus status,
    int pendingCount,
    SyncResult? syncStatus,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getStatusIcon(status, pendingCount),
              color: _getStatusColor(status, pendingCount, ref),
              size: DSTokens.fontM,
            ),
            const SizedBox(width: DSTokens.spaceS),
            Expanded(
              child: Text(
                _getStatusTitle(status, pendingCount),
                style: DSTypography.labelLarge.copyWith(
                  color: _getStatusColor(status, pendingCount, ref),
                  fontWeight: DSTokens.fontWeightSemiBold,
                ),
              ),
            ),
            if (pendingCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceS,
                  vertical: DSTokens.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSTokens.radiusS),
                ),
                child: Text(
                  '$pendingCount',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.warning,
                    fontWeight: DSTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!status.isConnected || pendingCount > 0) ...[
          const SizedBox(height: DSTokens.spaceS),
          Text(
            _getStatusDescription(status, pendingCount),
            style: DSTypography.bodySmall.copyWith(
              color: ref.colors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
        if (pendingCount > 0 && status.isConnected) ...[
          const SizedBox(height: DSTokens.spaceM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _forceSyncTapped(ref),
              icon: Icon(Icons.sync_rounded, size: DSTokens.fontM),
              label: Text(
                'Sync Now',
                style: DSTypography.buttonMedium.copyWith(
                  fontWeight: DSTokens.fontWeightMedium,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.brandPrimary,
                foregroundColor: DSColors.textOnColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: DSTokens.spaceM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSTokens.radiusM),
                ),
              ),
            ),
          ),
        ],
        if (syncStatus != null) ...[
          const SizedBox(height: DSTokens.spaceS),
          _buildSyncStatusInfo(ref, syncStatus),
        ],
      ],
    );
  }

  Widget _buildCompactStatus(
    WidgetRef ref,
    ConnectivityStatus status,
    int pendingCount,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getStatusIcon(status, pendingCount),
          color: _getStatusColor(status, pendingCount, ref),
          size: DSTokens.fontS,
        ),
        const SizedBox(width: DSTokens.spaceS),
        Text(
          _getCompactStatusText(status, pendingCount),
          style: DSTypography.labelMedium.copyWith(
            color: _getStatusColor(status, pendingCount, ref),
            fontWeight: DSTokens.fontWeightMedium,
          ),
        ),
        if (pendingCount > 0) ...[
          const SizedBox(width: DSTokens.spaceS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceS,
              vertical: DSTokens.spaceXS / 2,
            ),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DSTokens.radiusS),
            ),
            child: Text(
              '$pendingCount',
              style: DSTypography.labelSmall.copyWith(
                color: DSColors.warning,
                fontWeight: DSTokens.fontWeightBold,
                fontSize: DSTokens.fontXS,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSyncStatusInfo(WidgetRef ref, SyncResult syncStatus) {
    final color = syncStatus.isSuccess ? DSColors.success : DSColors.error;

    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            syncStatus.isSuccess
                ? Icons.check_circle_rounded
                : Icons.error_rounded,
            color: color,
            size: DSTokens.fontS,
          ),
          const SizedBox(width: DSTokens.spaceS),
          Expanded(
            child: Text(
              syncStatus.message,
              style: DSTypography.labelSmall.copyWith(
                color: color,
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: DSTokens.fontS,
            height: DSTokens.fontS,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(ref.colors.textSecondary),
            ),
          ),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            'Checking connection...',
            style: DSTypography.labelMedium.copyWith(
              color: ref.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DSColors.error,
            size: DSTokens.fontS,
          ),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            'Connection error',
            style: DSTypography.labelMedium.copyWith(color: DSColors.error),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(
    ConnectivityStatus status,
    int pendingCount,
    WidgetRef ref,
  ) {
    if (!status.isConnected) {
      return DSColors.error;
    } else if (pendingCount > 0) {
      return DSColors.warning;
    } else {
      return DSColors.success;
    }
  }

  IconData _getStatusIcon(ConnectivityStatus status, int pendingCount) {
    if (!status.isConnected) {
      return Icons.cloud_off_rounded;
    } else if (pendingCount > 0) {
      return Icons.cloud_sync_rounded;
    } else {
      return Icons.cloud_done_rounded;
    }
  }

  String _getStatusTitle(ConnectivityStatus status, int pendingCount) {
    if (!status.isConnected) {
      return 'Working Offline';
    } else if (pendingCount > 0) {
      return 'Syncing Data';
    } else {
      return 'Online';
    }
  }

  String _getStatusDescription(ConnectivityStatus status, int pendingCount) {
    if (!status.isConnected) {
      return 'Some features may be limited. Changes will sync when connection is restored.';
    } else if (pendingCount > 0) {
      return 'Syncing $pendingCount pending operation${pendingCount == 1 ? '' : 's'} with server.';
    } else {
      return 'All data is up to date.';
    }
  }

  String _getCompactStatusText(ConnectivityStatus status, int pendingCount) {
    if (!status.isConnected) {
      return 'Offline';
    } else if (pendingCount > 0) {
      return 'Syncing';
    } else {
      return status.displayName;
    }
  }

  void _forceSyncTapped(WidgetRef ref) {
    final syncService = ref.read(offlineSyncServiceProvider);
    syncService.forcSync().then((result) {
      ref.read(syncStatusProvider.notifier).updateStatus(result);

      // Clear status after a delay
      Future.delayed(const Duration(seconds: 3), () {
        ref.read(syncStatusProvider.notifier).clearStatus();
      });
    });
  }
}

/// App bar variation that shows connectivity status
class ConnectivityAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const ConnectivityAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        ...?actions,
        connectivityStatus.when(
          data: (status) => !status.isConnected
              ? const Padding(
                  padding: EdgeInsets.only(right: DSTokens.spaceS),
                  child: OfflineStatusIndicator(showDetails: false),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
