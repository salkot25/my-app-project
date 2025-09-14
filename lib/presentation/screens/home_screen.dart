import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../design_system/design_system.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: ref.colors.background,
        body: Center(
          child: Text(
            'Not authenticated',
            style: TextStyle(color: ref.colors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ref.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: DSTokens.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DSTokens.spaceL),

              // Clean Header Section
              _buildHeaderSection(currentUser, ref),

              SizedBox(height: DSTokens.spaceXXL),

              // Modern Stats Grid
              _buildStatsSection(currentUser, ref),

              SizedBox(height: DSTokens.spaceXXL),

              // Daily Inspiration
              _buildInspirationSection(ref),

              SizedBox(height: DSTokens.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(User currentUser, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          _getGreeting(),
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textSecondary,
          ),
        ),
        SizedBox(height: DSTokens.spaceXS),

        // Name
        Text(
          currentUser.name,
          style: DSTypography.displayMedium.copyWith(
            color: ref.colors.textPrimary,
          ),
        ),
        SizedBox(height: DSTokens.spaceM),

        // Role badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DSTokens.spaceM,
            vertical: DSTokens.spaceS,
          ),
          decoration: BoxDecoration(
            color: _getRoleColor(currentUser.role).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSTokens.radiusCircle),
            border: Border.all(
              color: _getRoleColor(currentUser.role).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(currentUser.role),
                size: DSTokens.spaceM,
                color: _getRoleColor(currentUser.role),
              ),
              SizedBox(width: DSTokens.spaceS),
              Text(
                currentUser.role.value.toUpperCase(),
                style: DSTypography.labelSmall.copyWith(
                  color: _getRoleColor(currentUser.role),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(User currentUser, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(DSTokens.spaceXL),
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusXL),
        border: Border.all(color: ref.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: DSTokens.spaceXS,
                height: DSTokens.spaceXL,
                decoration: BoxDecoration(
                  color: _getRoleColor(currentUser.role),
                  borderRadius: BorderRadius.circular(DSTokens.radiusXS),
                ),
              ),
              SizedBox(width: DSTokens.spaceM),
              Text(
                'Account Status',
                style: DSTypography.headlineMedium.copyWith(
                  color: ref.colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: DSTokens.spaceL),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Status',
                  currentUser.status.value.toUpperCase(),
                  _getStatusColor(currentUser.status),
                  ref,
                ),
              ),
              SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: _buildStatCard(
                  'Joined',
                  _formatDate(currentUser.createdAt),
                  ref.colors.textSecondary,
                  ref,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color valueColor,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: ref.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(color: ref.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DSTypography.labelMedium.copyWith(
              color: ref.colors.textSecondary,
            ),
          ),
          SizedBox(height: DSTokens.spaceS),
          Text(
            value,
            style: DSTypography.labelLarge.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationSection(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DSTokens.spaceXL),
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(color: ref.colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: ref.colors.textSecondary,
            size: DSTokens.spaceXL,
          ),
          SizedBox(height: DSTokens.spaceM),
          Text(
            _getInspirationalQuote(),
            textAlign: TextAlign.center,
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getInspirationalQuote() {
    final quotes = [
      'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'The only way to do great work is to love what you do.',
      'Innovation distinguishes between a leader and a follower.',
      'Your limitation—it\'s only your imagination.',
      'Dream it. Wish it. Do it.',
      'Stay focused and never give up.',
    ];

    final index = DateTime.now().day % quotes.length;
    return quotes[index];
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF8B5CF6); // Modern purple
      case UserRole.moderator:
        return const Color(0xFF3B82F6); // Modern blue
      case UserRole.user:
        return const Color(0xFF6B7280); // Modern gray
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.moderator:
        return Icons.verified_user_rounded;
      case UserRole.user:
        return Icons.person_rounded;
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return const Color(0xFF10B981); // Modern green
      case UserStatus.unverified:
        return const Color(0xFFF59E0B); // Modern amber
      case UserStatus.suspended:
        return const Color(0xFFEF4444); // Modern red
    }
  }
}
