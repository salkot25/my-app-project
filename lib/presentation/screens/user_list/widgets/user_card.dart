import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/entities/user_status.dart';
import '../../../providers/auth_provider.dart';
import '../../../../design_system/utils/role_colors.dart';
import '../../../../design_system/utils/status_utils.dart';
import 'user_detail_dialog.dart';

class UserCard extends ConsumerStatefulWidget {
  final User user;
  final bool isCurrentUser;
  final bool isEnabled;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(UserRole)? onRoleChanged;
  final Function(UserStatus)? onStatusChanged;

  const UserCard({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.isEnabled,
    this.onEdit,
    this.onDelete,
    this.onRoleChanged,
    this.onStatusChanged,
  });

  @override
  ConsumerState<UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: widget.isEnabled
                  ? () => _showUserDetail(context, ref)
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceL,
                  vertical: DSTokens.spaceS,
                ),
                decoration: BoxDecoration(
                  color: ref.colors.surface,
                  borderRadius: BorderRadius.circular(
                    DSTokens.radiusL,
                  ), // Increased radius
                  border: Border.all(
                    color: _isHovered
                        ? RoleColors.getRoleColorWithAlpha(
                            widget.user.role,
                            0.3,
                          )
                        : ref.colors.border,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DSColors.black.withValues(
                        alpha: _isHovered ? 0.08 : 0.02,
                      ),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DSTokens.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User header (name, email, current user badge)
                      _buildUserHeader(ref),
                      const SizedBox(
                        height: DSTokens.spaceL,
                      ), // Increased spacing
                      // User details (role, status, actions)
                      _buildUserDetails(ref),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserDetail(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final currentUser = authState.domainUser;
    final canManageUser =
        currentUser?.canViewAllUsers == true &&
        currentUser?.uid != widget.user.uid;

    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(
        user: widget.user,
        onRoleChanged: canManageUser && currentUser?.canChangeRoles == true
            ? widget.onRoleChanged
            : null,
        onStatusChanged: canManageUser && currentUser?.canVerifyUsers == true
            ? widget.onStatusChanged
            : null,
      ),
    );
  }

  Widget _buildUserHeader(WidgetRef ref) {
    return Row(
      children: [
        // Enhanced Avatar with better styling
        Container(
          width: 56, // Increased size
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                RoleColors.getRoleColorWithAlpha(widget.user.role, 0.1),
                RoleColors.getRoleColorWithAlpha(widget.user.role, 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: RoleColors.getRoleColorWithAlpha(widget.user.role, 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.user.name.isNotEmpty
                  ? widget.user.name[0].toUpperCase()
                  : 'U',
              style: DSTypography.headlineLarge.copyWith(
                color: RoleColors.getRoleColor(widget.user.role),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: DSTokens.spaceL),

        // User info - improved layout
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.user.name,
                      style: DSTypography.headlineMedium.copyWith(
                        color: ref.colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isCurrentUser) ...[
                    const SizedBox(width: DSTokens.spaceS),
                    _buildCurrentUserBadge(ref),
                  ],
                ],
              ),
              const SizedBox(height: DSTokens.spaceXS),
              Text(
                widget.user.email,
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserBadge(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSTokens.spaceS),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        'You',
        style: DSTypography.labelMedium.copyWith(
          color: const Color(0xFF10B981),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserDetails(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role and Status badges
        Row(
          children: [
            // Role badge
            _buildBadge(
              ref,
              widget.user.role.value.toUpperCase(),
              RoleColors.getRoleColor(widget.user.role),
              Icons.admin_panel_settings_rounded,
            ),
            const SizedBox(width: DSTokens.spaceM),

            // Status badge
            _buildBadge(
              ref,
              widget.user.status.value.toUpperCase(),
              StatusUtils.getStatusColor(widget.user.status),
              StatusUtils.getStatusIcon(widget.user.status),
            ),

            const Spacer(),

            // Action buttons - moved to bottom area for better UX
            if (widget.onDelete != null && !widget.isCurrentUser)
              _buildActionButton(
                ref,
                icon: Icons.delete_outline,
                color: DSColors.error,
                onTap: widget.isEnabled ? widget.onDelete : null,
                tooltip: 'Delete user',
              ),
          ],
        ),

        // Additional info section (can be expanded later)
        if (_shouldShowAdditionalInfo()) ...[
          const SizedBox(height: DSTokens.spaceM),
          _buildAdditionalInfo(ref),
        ],
      ],
    );
  }

  bool _shouldShowAdditionalInfo() {
    // Show additional info for current user or when hovered
    return widget.isCurrentUser || _isHovered;
  }

  Widget _buildAdditionalInfo(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: ref.colors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
        border: Border.all(color: ref.colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: ref.colors.textTertiary),
          const SizedBox(width: DSTokens.spaceS),
          Expanded(
            child: Text(
              widget.isCurrentUser
                  ? 'This is your account'
                  : 'Tap to view details',
              style: DSTypography.bodySmall.copyWith(
                color: ref.colors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    WidgetRef ref, {
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DSTokens.spaceS),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSTokens.radiusS),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color.withValues(alpha: widget.isEnabled ? 1.0 : 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(WidgetRef ref, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceS,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSTokens.radiusM), // More rounded
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            label,
            style: DSTypography.labelMedium.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
