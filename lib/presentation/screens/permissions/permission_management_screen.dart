import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/design_system.dart';
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header Section - same style as other screens
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSTokens.spaceL,
                  DSTokens.spaceL,
                  DSTokens.spaceL,
                  0,
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: ref.colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(DSTokens.radiusL),
                        border: Border.all(color: ref.colors.border, width: 1),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: ref.colors.textPrimary,
                          size: DSTokens.fontL,
                        ),
                        tooltip: 'Back',
                      ),
                    ),

                    const SizedBox(width: DSTokens.spaceL),

                    // Title section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Permissions',
                            style: DSTypography.displaySmall.copyWith(
                              color: ref.colors.textPrimary,
                              fontWeight: DSTokens.fontWeightBold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: DSTokens.spaceXS),
                          Text(
                            'Control which device features this app can access',
                            style: DSTypography.bodyLarge.copyWith(
                              color: ref.colors.textSecondary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DSTokens.spaceL),

              // Content
              Expanded(
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
                      SliverToBoxAdapter(
                        child: _buildCriticalPermissionsSection(),
                      ),

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

          // Grouped permission tiles by category
          ...AppPermissionType.values
                  .where(
                    (type) => _getPermissionCategory(type) == 'Device Access',
                  )
                  .isNotEmpty
              ? [
                  _buildCategoryHeader(
                    'Device Access',
                    Icons.smartphone_rounded,
                  ),
                  ...AppPermissionType.values
                      .where(
                        (type) =>
                            _getPermissionCategory(type) == 'Device Access',
                      )
                      .map((type) => _buildPermissionTile(type)),
                  const SizedBox(height: DSTokens.spaceM),
                ]
              : <Widget>[],

          ...AppPermissionType.values
                  .where(
                    (type) => _getPermissionCategory(type) == 'Media & Files',
                  )
                  .isNotEmpty
              ? [
                  _buildCategoryHeader(
                    'Media & Files',
                    Icons.photo_library_rounded,
                  ),
                  ...AppPermissionType.values
                      .where(
                        (type) =>
                            _getPermissionCategory(type) == 'Media & Files',
                      )
                      .map((type) => _buildPermissionTile(type)),
                  const SizedBox(height: DSTokens.spaceM),
                ]
              : <Widget>[],

          ...AppPermissionType.values
                  .where(
                    (type) => _getPermissionCategory(type) == 'Communication',
                  )
                  .isNotEmpty
              ? [
                  _buildCategoryHeader('Communication', Icons.chat_rounded),
                  ...AppPermissionType.values
                      .where(
                        (type) =>
                            _getPermissionCategory(type) == 'Communication',
                      )
                      .map((type) => _buildPermissionTile(type)),
                ]
              : <Widget>[],

          // Fallback for uncategorized permissions
          ...AppPermissionType.values
              .where((type) => _getPermissionCategory(type) == 'Other')
              .map((type) => _buildPermissionTile(type)),
        ],
      ),
    );
  }

  String _getPermissionCategory(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
      case AppPermissionType.microphone:
      case AppPermissionType.location:
        return 'Device Access';
      case AppPermissionType.storage:
      case AppPermissionType.photos:
        return 'Media & Files';
      case AppPermissionType.contacts:
      case AppPermissionType.phone:
        return 'Communication';
      default:
        return 'Other';
    }
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSTokens.spaceM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSTokens.spaceXS),
            decoration: BoxDecoration(
              color: ref.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(DSTokens.radiusS),
            ),
            child: Icon(
              icon,
              size: DSTokens.fontM,
              color: ref.colors.textSecondary,
            ),
          ),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            title,
            style: DSTypography.bodyLarge.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: DSTokens.fontWeightSemiBold,
            ),
          ),
          const SizedBox(width: DSTokens.spaceS),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ref.colors.border, Colors.transparent],
                ),
              ),
            ),
          ),
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
          margin: const EdgeInsets.only(bottom: DSTokens.spaceS),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: permissionStatus?.canToggle == true
                  ? () => _togglePermission(type, isGranted)
                  : null,
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              child: Container(
                padding: const EdgeInsets.all(DSTokens.spaceL),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Enhanced icon with gradient background
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (permissionStatus?.statusColor ??
                                        DSColors.textSecondary)
                                    .withValues(alpha: 0.15),
                                (permissionStatus?.statusColor ??
                                        DSColors.textSecondary)
                                    .withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            border: Border.all(
                              color:
                                  (permissionStatus?.statusColor ??
                                          DSColors.textSecondary)
                                      .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            type.icon,
                            color:
                                permissionStatus?.statusColor ??
                                DSColors.textSecondary,
                            size: DSTokens.fontXL,
                          ),
                        ),
                        const SizedBox(width: DSTokens.spaceL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      type.displayName,
                                      style: DSTypography.headlineSmall
                                          .copyWith(
                                            color: ref.colors.textPrimary,
                                            fontWeight:
                                                DSTokens.fontWeightSemiBold,
                                          ),
                                    ),
                                  ),
                                  if (type.isCritical) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DSTokens.spaceS,
                                        vertical: DSTokens.spaceXS,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            DSColors.error.withValues(
                                              alpha: 0.15,
                                            ),
                                            DSColors.error.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          DSTokens.radiusS,
                                        ),
                                        border: Border.all(
                                          color: DSColors.error.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.priority_high_rounded,
                                            size: 12,
                                            color: DSColors.error,
                                          ),
                                          const SizedBox(
                                            width: DSTokens.spaceXS,
                                          ),
                                          Text(
                                            'Required',
                                            style: DSTypography.labelSmall
                                                .copyWith(
                                                  color: DSColors.error,
                                                  fontSize: 10,
                                                  fontWeight: DSTokens
                                                      .fontWeightSemiBold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: DSTokens.spaceXS),
                              Text(
                                type.description,
                                style: DSTypography.bodyMedium.copyWith(
                                  color: ref.colors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DSTokens.spaceL),
                        if (permissionStatus?.canToggle == true)
                          Switch.adaptive(
                            value: isGranted,
                            onChanged: (value) =>
                                _togglePermission(type, !value),
                            activeTrackColor: DSColors.success,
                            activeThumbColor: DSColors.white,
                            inactiveThumbColor: ref.colors.textTertiary,
                            inactiveTrackColor: ref.colors.surfaceContainer,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(DSTokens.spaceS),
                            decoration: BoxDecoration(
                              color: ref.colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusS,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: ref.colors.textTertiary,
                              size: DSTokens.fontM,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: DSTokens.spaceM),
                    // Status row with enhanced styling
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSTokens.spaceM,
                            vertical: DSTokens.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (permissionStatus?.statusColor ??
                                        DSColors.textTertiary)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusS,
                            ),
                            border: Border.all(
                              color:
                                  (permissionStatus?.statusColor ??
                                          DSColors.textTertiary)
                                      .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                permissionStatus?.statusIcon ??
                                    Icons.help_outline,
                                size: DSTokens.fontS,
                                color:
                                    permissionStatus?.statusColor ??
                                    DSColors.textTertiary,
                              ),
                              const SizedBox(width: DSTokens.spaceS),
                              Text(
                                permissionStatus?.displayName ?? 'Unknown',
                                style: DSTypography.labelMedium.copyWith(
                                  color:
                                      permissionStatus?.statusColor ??
                                      DSColors.textTertiary,
                                  fontWeight: DSTokens.fontWeightSemiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (isGranted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceS,
                              vertical: DSTokens.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              color: DSColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusS,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: DSColors.success,
                                ),
                                const SizedBox(width: DSTokens.spaceXS),
                                Text(
                                  'Active',
                                  style: DSTypography.labelSmall.copyWith(
                                    color: DSColors.success,
                                    fontWeight: DSTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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
}
