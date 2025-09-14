import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/design_system.dart';
import '../../../design_system/utils/theme_colors.dart';
import '../../../domain/entities/app_permission.dart';
import '../../providers/permission_provider.dart';

/// Detailed App Permissions Management Screen
/// Menampilkan semua permissions dengan toggle controls dan descriptions
class PermissionManagementScreen extends ConsumerStatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  ConsumerState<PermissionManagementScreen> createState() =>
      _PermissionManagementScreenState();
}

class _PermissionManagementScreenState
    extends ConsumerState<PermissionManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.colors.background,
      appBar: AppBar(
        backgroundColor: ref.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded, color: ref.colors.textPrimary),
        ),
        title: Text(
          'App Permissions',
          style: DSTypography.headlineSmall.copyWith(
            color: ref.colors.textPrimary,
            fontWeight: DSTokens.fontWeightBold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showPermissionInfo,
            icon: Icon(
              Icons.info_outline_rounded,
              color: ref.colors.textSecondary,
            ),
          ),
          const SizedBox(width: DSTokens.spaceS),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ref.colors.border,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: DSColors.brandPrimary,
          onRefresh: () async {
            // Refresh permission states
            ref.invalidate(permissionProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Permission Summary Header
              SliverToBoxAdapter(child: _buildPermissionSummary()),

              // Critical Permissions Section
              SliverToBoxAdapter(child: _buildCriticalPermissionsSection()),

              // All Permissions List
              SliverToBoxAdapter(child: _buildAllPermissionsSection()),

              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: DSTokens.spaceXL),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSummary() {
    return Consumer(
      builder: (context, ref, child) {
        final summary = ref.watch(permissionSummaryProvider);
        final grantedCount = summary['granted'] ?? 0;
        final deniedCount = summary['denied'] ?? 0;
        final notRequestedCount = summary['notRequested'] ?? 0;

        return Container(
          margin: const EdgeInsets.all(DSTokens.spaceM),
          padding: const EdgeInsets.all(DSTokens.spaceL),
          decoration: BoxDecoration(
            color: ref.colors.surface,
            borderRadius: BorderRadius.circular(DSTokens.radiusL),
            boxShadow: [
              BoxShadow(
                color: ref.colors.shadowColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DSTokens.spaceS),
                    decoration: BoxDecoration(
                      color: DSColors.brandPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DSTokens.radiusM),
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      color: DSColors.brandPrimary,
                      size: DSTokens.fontL,
                    ),
                  ),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permission Overview',
                          style: DSTypography.headlineSmall.copyWith(
                            color: ref.colors.textPrimary,
                            fontWeight: DSTokens.fontWeightBold,
                          ),
                        ),
                        const SizedBox(height: DSTokens.spaceXS),
                        Text(
                          'Manage app access to device features',
                          style: DSTypography.bodyMedium.copyWith(
                            color: ref.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSTokens.spaceL),

              // Summary Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Granted',
                      value: grantedCount.toString(),
                      color: DSColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Pending',
                      value: notRequestedCount.toString(),
                      color: DSColors.warning,
                      icon: Icons.pending_rounded,
                    ),
                  ),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Denied',
                      value: deniedCount.toString(),
                      color: DSColors.error,
                      icon: Icons.block_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: DSTokens.fontL),
          const SizedBox(height: DSTokens.spaceS),
          Text(
            value,
            style: DSTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: DSTokens.fontWeightBold,
            ),
          ),
          Text(
            label,
            style: DSTypography.labelSmall.copyWith(
              color: color,
              fontWeight: DSTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalPermissionsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final criticalDenied = ref.watch(criticalPermissionsDeniedProvider);

        if (criticalDenied.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
            DSTokens.spaceM,
            0,
            DSTokens.spaceM,
            DSTokens.spaceM,
          ),
          padding: const EdgeInsets.all(DSTokens.spaceL),
          decoration: BoxDecoration(
            color: DSColors.warning.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(DSTokens.radiusL),
            border: Border.all(
              color: DSColors.warning.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: DSColors.warning,
                    size: DSTokens.fontL,
                  ),
                  const SizedBox(width: DSTokens.spaceS),
                  Text(
                    'Critical Permissions',
                    style: DSTypography.headlineSmall.copyWith(
                      color: DSColors.warning,
                      fontWeight: DSTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSTokens.spaceS),
              Text(
                'These permissions are required for core app functionality. Please grant them for the best experience.',
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DSTokens.spaceM),
              ...criticalDenied.map(
                (type) => _buildCriticalPermissionTile(type),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticalPermissionTile(AppPermissionType type) {
    return Container(
      margin: const EdgeInsets.only(bottom: DSTokens.spaceS),
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(
          color: DSColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSTokens.spaceS),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSTokens.spaceS),
            ),
            child: Icon(
              type.icon,
              color: DSColors.warning,
              size: DSTokens.fontM,
            ),
          ),
          const SizedBox(width: DSTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: DSTypography.bodyLarge.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: DSTokens.fontWeightSemiBold,
                  ),
                ),
                Text(
                  type.description,
                  style: DSTypography.bodySmall.copyWith(
                    color: ref.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSTokens.spaceM),
          ElevatedButton(
            onPressed: () => _requestPermission(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: DSColors.warning,
              foregroundColor: DSColors.textOnColor,
              elevation: 0,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
            ),
            child: Text(
              'Grant',
              style: DSTypography.labelMedium.copyWith(
                fontWeight: DSTokens.fontWeightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPermissionsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        DSTokens.spaceM,
        0,
        DSTokens.spaceM,
        DSTokens.spaceM,
      ),
      padding: const EdgeInsets.all(DSTokens.spaceL),
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        boxShadow: [
          BoxShadow(
            color: ref.colors.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Permissions',
            style: DSTypography.headlineSmall.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: DSTokens.fontWeightBold,
            ),
          ),
          const SizedBox(height: DSTokens.spaceS),
          Text(
            'Control which device features this app can access',
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSTokens.spaceL),

          // All permission tiles
          ...AppPermissionType.values.map((type) => _buildPermissionTile(type)),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(AppPermissionType type) {
    return Consumer(
      builder: (context, ref, child) {
        final permissionStatus = ref.watch(permissionStatusProvider(type));
        final isGranted = permissionStatus == PermissionStatus.granted;

        return Container(
          margin: const EdgeInsets.only(bottom: DSTokens.spaceM),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: permissionStatus?.canToggle == true
                  ? () => _togglePermission(type, isGranted)
                  : null,
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              child: Container(
                padding: const EdgeInsets.all(DSTokens.spaceM),
                decoration: BoxDecoration(
                  color: isGranted
                      ? DSColors.success.withValues(alpha: 0.05)
                      : ref.colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(DSTokens.radiusM),
                  border: Border.all(
                    color: isGranted
                        ? DSColors.success.withValues(alpha: 0.2)
                        : ref.colors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DSTokens.spaceS),
                      decoration: BoxDecoration(
                        color:
                            (permissionStatus?.statusColor ??
                                    DSColors.textSecondary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSTokens.spaceS),
                      ),
                      child: Icon(
                        type.icon,
                        color:
                            permissionStatus?.statusColor ??
                            DSColors.textSecondary,
                        size: DSTokens.fontL,
                      ),
                    ),
                    const SizedBox(width: DSTokens.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                type.displayName,
                                style: DSTypography.bodyLarge.copyWith(
                                  color: ref.colors.textPrimary,
                                  fontWeight: DSTokens.fontWeightSemiBold,
                                ),
                              ),
                              if (type.isCritical) ...[
                                const SizedBox(width: DSTokens.spaceS),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DSTokens.spaceXS,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DSColors.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      DSTokens.radiusXS,
                                    ),
                                  ),
                                  child: Text(
                                    'Required',
                                    style: DSTypography.labelSmall.copyWith(
                                      color: DSColors.error,
                                      fontSize: 10,
                                      fontWeight: DSTokens.fontWeightMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: DSTokens.spaceXS),
                          Text(
                            type.description,
                            style: DSTypography.bodySmall.copyWith(
                              color: ref.colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: DSTokens.spaceXS),
                          Row(
                            children: [
                              Icon(
                                permissionStatus?.statusIcon ??
                                    Icons.help_outline,
                                size: DSTokens.fontS,
                                color:
                                    permissionStatus?.statusColor ??
                                    DSColors.textTertiary,
                              ),
                              const SizedBox(width: DSTokens.spaceXS),
                              Text(
                                permissionStatus?.displayName ?? 'Unknown',
                                style: DSTypography.labelSmall.copyWith(
                                  color:
                                      permissionStatus?.statusColor ??
                                      DSColors.textTertiary,
                                  fontWeight: DSTokens.fontWeightMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DSTokens.spaceM),
                    if (permissionStatus?.canToggle == true)
                      Switch.adaptive(
                        value: isGranted,
                        onChanged: (value) => _togglePermission(type, !value),
                        activeColor: DSColors.success,
                        activeTrackColor: DSColors.success.withValues(
                          alpha: 0.3,
                        ),
                        inactiveThumbColor: ref.colors.textTertiary,
                        inactiveTrackColor: ref.colors.surfaceContainer,
                      )
                    else
                      Icon(
                        Icons.lock_outline,
                        color: ref.colors.textTertiary,
                        size: DSTokens.fontM,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePermission(
    AppPermissionType type,
    bool currentlyGranted,
  ) async {
    HapticFeedback.lightImpact();

    if (currentlyGranted) {
      // Revoke permission
      await ref
          .read(permissionProvider.notifier)
          .updatePermissionStatus(
            type: type,
            status: PermissionStatus.denied,
            reasonDenied: 'User manually disabled permission',
          );
    } else {
      // Request permission
      await _requestPermission(type);
    }
  }

  Future<void> _requestPermission(AppPermissionType type) async {
    HapticFeedback.lightImpact();

    final status = await ref
        .read(permissionProvider.notifier)
        .requestPermission(type);

    String message;
    Color backgroundColor;
    IconData icon;

    switch (status) {
      case PermissionStatus.granted:
        message = '${type.displayName} permission granted';
        backgroundColor = DSColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case PermissionStatus.denied:
        message = '${type.displayName} permission denied';
        backgroundColor = DSColors.warning;
        icon = Icons.block_rounded;
        break;
      case PermissionStatus.permanentlyDenied:
        message = '${type.displayName} permanently denied. Check app settings.';
        backgroundColor = DSColors.error;
        icon = Icons.settings_rounded;
        break;
      default:
        message = 'Unable to request ${type.displayName} permission';
        backgroundColor = DSColors.error;
        icon = Icons.error_rounded;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: DSColors.textOnColor, size: DSTokens.fontM),
              const SizedBox(width: DSTokens.spaceS),
              Expanded(
                child: Text(
                  message,
                  style: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textOnColor,
                    fontWeight: DSTokens.fontWeightMedium,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(DSTokens.spaceM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSTokens.radiusM),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPermissionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceS),
              decoration: BoxDecoration(
                color: DSColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: DSColors.info,
                size: DSTokens.fontL,
              ),
            ),
            const SizedBox(width: DSTokens.spaceM),
            Text(
              'About Permissions',
              style: DSTypography.headlineSmall.copyWith(
                color: ref.colors.textPrimary,
                fontWeight: DSTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App permissions control what device features this app can access. You can grant or deny permissions at any time.',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: DSTokens.spaceM),
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceM),
              decoration: BoxDecoration(
                color: DSColors.brandPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
                border: Border.all(
                  color: DSColors.brandPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Critical permissions are required for core app functionality and should be granted for the best experience.',
                style: DSTypography.bodySmall.copyWith(
                  color: DSColors.brandPrimary,
                  fontWeight: DSTokens.fontWeightMedium,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: ref.colors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: DSTokens.spaceL,
                vertical: DSTokens.spaceM,
              ),
            ),
            child: Text(
              'Got it',
              style: DSTypography.buttonMedium.copyWith(
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
