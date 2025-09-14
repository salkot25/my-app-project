import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/utils/theme_colors.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final User currentUser;

  const EditProfileDialog({super.key, required this.currentUser});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentUser.name;
    _emailController.text = widget.currentUser.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error; // Purple equivalent for admin
      case UserRole.moderator:
        return DSColors.brandPrimary; // Blue for moderator
      case UserRole.user:
        return DSColors
            .brandPrimary; // Use brandPrimary for better theme compatibility
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref
            .read(authProvider.notifier)
            .updateProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
            );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: DSTypography.bodyMedium.copyWith(
                  color: DSColors.textOnColor,
                ),
              ),
              backgroundColor: DSColors.success,
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
                'Failed to update profile: ${e.toString()}',
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
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
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

                        // Profile Avatar
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
                            Icons.edit_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.spaceXL + DSTokens.spaceS, // 40px
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceM),

                        // Title and subtitle
                        Text(
                          'Edit Profile',
                          style: DSTypography.headlineLarge.copyWith(
                            color: DSColors.textOnColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: DSTokens.spaceXS),
                        Text(
                          'Update your profile information',
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
                      // Name Field
                      Text(
                        'Full Name',
                        style: DSTypography.labelMedium.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceS),
                      TextFormField(
                        controller: _nameController,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: ref.colors.textSecondary),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.fontL + DSTokens.spaceXS, // 22px
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DSTokens.spaceL),

                      // Email Field
                      Text(
                        'Email Address',
                        style: DSTypography.labelMedium.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceS),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(color: ref.colors.textSecondary),
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: _getRoleColor(widget.currentUser.role),
                            size: DSTokens.fontL + DSTokens.spaceXS, // 22px
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
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
                      onPressed: _isLoading ? null : _saveProfile,
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
                              'Save Changes',
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
}
