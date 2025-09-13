import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../design_system/design_system.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: DSTypography.headlineLarge.copyWith(
            fontSize: DSTokens.fontXL,
            fontWeight: DSTokens.fontWeightSemiBold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: DSColors.lightSurface,
        foregroundColor: DSColors.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: DSColors.lightSurface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Container(
        color: DSColors.lightBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceL,
              vertical: DSTokens.spaceXL,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: DSTokens.spaceL),

                  // Modern Icon Container
                  Container(
                    width: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
                    height: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DSColors.success.withValues(alpha: 0.2),
                          DSColors.success.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
                      color: DSColors.success,
                    ),
                  ),

                  const SizedBox(height: DSTokens.spaceXL),

                  // Welcome Text
                  Text(
                    'Join Us Today',
                    style: DSTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DSTokens.spaceS),

                  Text(
                    'Create your account to get started',
                    style: DSTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DSTokens.spaceXXL),

                  // Registration Form Container
                  Container(
                    padding: const EdgeInsets.all(DSTokens.spaceXL),
                    decoration: BoxDecoration(
                      color: DSColors.lightSurface,
                      borderRadius: BorderRadius.circular(DSTokens.radiusXL),
                      boxShadow: [DSTokens.shadowS],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name Field
                        TextFormField(
                          controller: _nameController,
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: DSTypography.labelMedium,
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: DSColors.textSecondary,
                              size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.brandPrimary,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXXS / 2, // 1px
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            filled: true,
                            fillColor: DSColors.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceM,
                              vertical: DSTokens.spaceM,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: DSTokens.spaceL),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: DSTypography.labelMedium,
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: DSColors.textSecondary,
                              size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.brandPrimary,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXXS / 2, // 1px
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            filled: true,
                            fillColor: DSColors.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceM,
                              vertical: DSTokens.spaceM,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: DSTokens.spaceL),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: DSTypography.labelMedium,
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: DSColors.textSecondary,
                              size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: DSColors.textSecondary,
                                size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.brandPrimary,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXXS / 2, // 1px
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            filled: true,
                            fillColor: DSColors.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceM,
                              vertical: DSTokens.spaceM,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: DSTokens.spaceL),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: DSTypography.labelMedium,
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: DSColors.textSecondary,
                              size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: DSColors.textSecondary,
                                size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.brandPrimary,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXXS / 2, // 1px
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                              borderSide: BorderSide(
                                color: DSColors.error,
                                width: DSTokens.spaceXS / 2, // 2px
                              ),
                            ),
                            filled: true,
                            fillColor: DSColors.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceM,
                              vertical: DSTokens.spaceM,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: DSTokens.spaceL),

                        // Error Message
                        if (authState.error != null)
                          Container(
                            padding: const EdgeInsets.all(DSTokens.spaceM),
                            margin: const EdgeInsets.only(
                              bottom: DSTokens.spaceL,
                            ),
                            decoration: BoxDecoration(
                              color: DSColors.error.withValues(alpha: 0.1),
                              border: Border.all(
                                color: DSColors.error.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: DSColors.error,
                                  size:
                                      DSTokens.fontL + DSTokens.spaceXS, // 22px
                                ),
                                const SizedBox(
                                  width: DSTokens.spaceS + DSTokens.spaceXS,
                                ), // 12px
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: DSTypography.bodySmall.copyWith(
                                      color: DSColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Register Button
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DSColors.success,
                            foregroundColor: DSColors.textOnColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: DSTokens.spaceM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DSTokens.radiusM,
                              ),
                            ),
                            disabledBackgroundColor:
                                DSColors.interactiveDisabled,
                            disabledForegroundColor: DSColors.textSecondary,
                          ),
                          child: authState.isLoading
                              ? SizedBox(
                                  height:
                                      DSTokens.fontL + DSTokens.spaceXS, // 22px
                                  width:
                                      DSTokens.fontL + DSTokens.spaceXS, // 22px
                                  child: CircularProgressIndicator(
                                    strokeWidth: DSTokens.spaceXS / 2, // 2px
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      DSColors.textOnColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: DSTypography.buttonLarge,
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DSTokens.spaceL),

                  // Success Message for Account Creation
                  if (authState.firebaseUser != null && !authState.isVerified)
                    Container(
                      padding: const EdgeInsets.all(DSTokens.spaceL),
                      margin: const EdgeInsets.only(bottom: DSTokens.spaceL),
                      decoration: BoxDecoration(
                        color: DSColors.warning.withValues(alpha: 0.1),
                        border: Border.all(
                          color: DSColors.warning.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(DSTokens.radiusM),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(DSTokens.spaceS),
                                decoration: BoxDecoration(
                                  color: DSColors.warning.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.radiusS,
                                  ),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: DSColors.warning,
                                  size:
                                      DSTokens.fontL + DSTokens.spaceXS, // 22px
                                ),
                              ),
                              const SizedBox(
                                width: DSTokens.spaceS + DSTokens.spaceXS,
                              ), // 12px
                              Expanded(
                                child: Text(
                                  'Account Created Successfully!',
                                  style: DSTypography.bodyLarge.copyWith(
                                    color: DSColors.warning,
                                    fontWeight: DSTokens.fontWeightSemiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: DSTokens.spaceS + DSTokens.spaceXS,
                          ), // 12px
                          Text(
                            'Your account has been created successfully. Please wait for an admin to verify your account before you can access all features.',
                            style: DSTypography.bodySmall.copyWith(
                              color: DSColors.warning,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: DSTypography.bodySmall.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                context.go('/login');
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: DSColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSTokens.spaceS,
                            vertical: DSTokens.spaceXS,
                          ),
                        ),
                        child: Text('Sign In', style: DSTypography.link),
                      ),
                    ],
                  ),

                  const SizedBox(height: DSTokens.spaceXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
