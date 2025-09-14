import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failures.dart';

class UserSearchSection extends ConsumerWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final UserRole? roleFilter;
  final bool isEnabled;
  final Function(String) onSearchChanged;
  final Function(UserRole?) onRoleFilterChanged;

  const UserSearchSection({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.roleFilter,
    required this.isEnabled,
    required this.onSearchChanged,
    required this.onRoleFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceL,
        vertical: DSTokens.spaceM,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? DSColors.black.withValues(alpha: 0.3)
                  : DSColors.black.withValues(alpha: 0.08),
              blurRadius: isDark ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? DSColors.neutral700 : DSColors.neutral200,
            width: 0.5,
          ),
        ),
        child: _buildSearchBar(ref),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: ref.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(color: ref.colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Role filter dropdown
          _buildRoleDropdown(ref),
          Container(
            width: 1,
            height: 24,
            color: ref.colors.border.withValues(alpha: 0.3),
          ),
          // Search field
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ref.colors.textSecondary,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: ref.colors.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceM,
                  vertical: DSTokens.spaceM + 2,
                ),
              ),
              enabled: isEnabled,
              onChanged: onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSTokens.spaceM),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole?>(
          value: roleFilter,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: ref.colors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: DSTokens.spaceS),
              Text(
                'All Roles',
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: ref.colors.textSecondary,
          ),
          items: [
            DropdownMenuItem<UserRole?>(
              value: null,
              child: _buildDropdownItem(
                ref,
                Icons.people_outline_rounded,
                'All Roles',
              ),
            ),
            DropdownMenuItem<UserRole?>(
              value: UserRole.admin,
              child: _buildDropdownItem(
                ref,
                Icons.admin_panel_settings_rounded,
                'Admin',
              ),
            ),
            DropdownMenuItem<UserRole?>(
              value: UserRole.moderator,
              child: _buildDropdownItem(
                ref,
                Icons.shield_outlined,
                'Moderator',
              ),
            ),
            DropdownMenuItem<UserRole?>(
              value: UserRole.user,
              child: _buildDropdownItem(
                ref,
                Icons.person_outline_rounded,
                'User',
              ),
            ),
          ],
          onChanged: isEnabled ? onRoleFilterChanged : null,
          selectedItemBuilder: (context) => [
            _buildSelectedItem(ref, Icons.people_outline_rounded, 'All'),
            _buildSelectedItem(
              ref,
              Icons.admin_panel_settings_rounded,
              'Admin',
            ),
            _buildSelectedItem(ref, Icons.shield_outlined, 'Moderator'),
            _buildSelectedItem(ref, Icons.person_outline_rounded, 'User'),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(WidgetRef ref, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ref.colors.textSecondary),
        const SizedBox(width: DSTokens.spaceM),
        Text(
          text,
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedItem(WidgetRef ref, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: ref.colors.textSecondary),
        const SizedBox(width: DSTokens.spaceS),
        Text(
          text,
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
