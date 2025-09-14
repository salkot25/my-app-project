import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';

class PasswordChangeDialog extends ConsumerStatefulWidget {
  final User currentUser;

  const PasswordChangeDialog({super.key, required this.currentUser});

  @override
  ConsumerState<PasswordChangeDialog> createState() =>
      _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends ConsumerState<PasswordChangeDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error;
      case UserRole.moderator:
        return DSColors.brandPrimary;
      case UserRole.user:
        return DSColors.textSecondary;
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // TODO: Implement password change functionality
        // This would require adding a changePassword method to the AuthProvider
        // For now, we'll simulate the functionality

        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        // Show coming soon message for now
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password change feature coming soon!',
                style: DSTypography.bodyMedium.copyWith(
                  color: DSColors.textOnColor,
                ),
              ),
              backgroundColor: DSColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'An error occurred: ${e.toString()}',
                style: DSTypography.bodyMedium.copyWith(
                  color: DSColors.textOnColor,
                ),
              ),
              backgroundColor: DSColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DSColors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 720),
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusXL),
          boxShadow: [DSTokens.shadowM],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getRoleColor(widget.currentUser.role),
                    _getRoleColor(
                      widget.currentUser.role,
                    ).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSTokens.radiusXL),
                  topRight: Radius.circular(DSTokens.radiusXL),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -DSTokens.spaceL,
                    right: -DSTokens.spaceL,
                    child: Container(
                      width: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
                      height: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DSColors.textOnColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(DSTokens.spaceL),
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: DSColors.textOnColor.withValues(
                                alpha: 0.8,
                              ),
                              size: DSTokens.spaceL,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: DSColors.textOnColor.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.all(DSTokens.spaceS),
                            ),
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceS),

                        // Security Icon
                        Container(
                          width: DSTokens.spaceXXL * 2, // 96px
                          height: DSTokens.spaceXXL * 2, // 96px
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                DSColors.textOnColor,
                                DSColors.textOnColor.withValues(alpha: 0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: DSColors.textOnColor,
                              width: DSTokens.spaceXS / 2 + 1, // 3px
                            ),
                            boxShadow: [DSTokens.shadowS],
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.spaceXL + DSTokens.spaceS, // 40px
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceM),

                        // Title and subtitle
                        Text(
                          'Change Password',
                          style: DSTypography.headlineLarge.copyWith(
                            color: DSColors.textOnColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: DSTokens.spaceXS),
                        Text(
                          'Update your password for security',
                          style: DSTypography.bodySmall.copyWith(
                            color: DSColors.textOnColor.withValues(alpha: 0.8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DSTokens.spaceL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Password Field
                      Text(
                        'Current Password',
                        style: DSTypography.labelMedium.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceS),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: !_showCurrentPassword,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your current password',
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showCurrentPassword = !_showCurrentPassword;
                              });
                            },
                            icon: Icon(
                              _showCurrentPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: ref.colors.textSecondary,
                              size: DSTokens.fontL,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(
                              color: _getRoleColor(widget.currentUser.role),
                              width: DSTokens.spaceXS / 2, // 2px
                            ),
                          ),
                          filled: true,
                          fillColor: ref.colors.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DSTokens.spaceM,
                            vertical: DSTokens.spaceM,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DSTokens.spaceL),

                      // New Password Field
                      Text(
                        'New Password',
                        style: DSTypography.labelMedium.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceS),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your new password',
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showNewPassword = !_showNewPassword;
                              });
                            },
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: ref.colors.textSecondary,
                              size: DSTokens.fontL,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(
                              color: _getRoleColor(widget.currentUser.role),
                              width: DSTokens.spaceXS / 2, // 2px
                            ),
                          ),
                          filled: true,
                          fillColor: ref.colors.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DSTokens.spaceM,
                            vertical: DSTokens.spaceM,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                          ).hasMatch(value)) {
                            return 'Password must contain uppercase, lowercase, and number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DSTokens.spaceL),

                      // Confirm Password Field
                      Text(
                        'Confirm New Password',
                        style: DSTypography.labelMedium.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceS),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm your new password',
                          prefixIcon: Icon(
                            Icons.lock_person_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: ref.colors.textSecondary,
                              size: DSTokens.fontL,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(color: ref.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DSTokens.radiusM,
                            ),
                            borderSide: BorderSide(
                              color: _getRoleColor(widget.currentUser.role),
                              width: DSTokens.spaceXS / 2, // 2px
                            ),
                          ),
                          filled: true,
                          fillColor: ref.colors.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DSTokens.spaceM,
                            vertical: DSTokens.spaceM,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DSTokens.spaceM),

                      // Password requirements
                      Container(
                        padding: const EdgeInsets.all(DSTokens.spaceM),
                        decoration: BoxDecoration(
                          color: ref.colors.surfaceContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(DSTokens.radiusM),
                          border: Border.all(
                            color: ref.colors.border.withValues(alpha: 0.3),
                            width: DSTokens.spaceXXS / 2, // 1px
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Requirements:',
                              style: DSTypography.labelSmall.copyWith(
                                color: ref.colors.textPrimary,
                                fontWeight: DSTokens.fontWeightSemiBold,
                              ),
                            ),
                            const SizedBox(height: DSTokens.spaceS),
                            _buildRequirementItem('At least 8 characters long'),
                            _buildRequirementItem('Contains uppercase letter'),
                            _buildRequirementItem('Contains lowercase letter'),
                            _buildRequirementItem(
                              'Contains at least one number',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceL),
              decoration: BoxDecoration(
                color: ref.colors.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(DSTokens.radiusXL),
                  bottomRight: Radius.circular(DSTokens.radiusXL),
                ),
                border: Border(
                  top: BorderSide(
                    color: ref.colors.border,
                    width: DSTokens.spaceXXS / 2, // 1px
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: ref.colors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: DSTokens.spaceM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSTokens.radiusM),
                        ),
                      ),
                      child: Text('Cancel', style: DSTypography.buttonMedium),
                    ),
                  ),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRoleColor(widget.currentUser.role),
                        foregroundColor: DSColors.textOnColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: DSTokens.spaceM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSTokens.radiusM),
                        ),
                        disabledBackgroundColor: DSColors.interactiveDisabled,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: DSTokens.fontL,
                              width: DSTokens.fontL,
                              child: CircularProgressIndicator(
                                strokeWidth: DSTokens.spaceXS / 2, // 2px
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  DSColors.textOnColor,
                                ),
                              ),
                            )
                          : Text(
                              'Change Password',
                              style: DSTypography.buttonMedium,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSTokens.spaceXS),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: DSTokens.fontS,
            color: ref.colors.textPrimary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: DSTokens.spaceS),
          Expanded(
            child: Text(
              text,
              style: DSTypography.bodySmall.copyWith(
                color: ref.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
