import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../design_system/design_system.dart';
import 'index.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Animation controllers for enhanced UX
  late AnimationController _shakeController;
  late AnimationController _loadingController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _loadingController.repeat(); // Start loading animation

      await ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );

      // Stop loading animation only if widget is still mounted
      if (mounted && _loadingController.isAnimating) {
        _loadingController.stop();
      }

      // If registration failed, trigger error animation
      if (mounted && ref.read(authProvider).error != null) {
        _triggerErrorShake();
      }
    } else {
      _triggerErrorShake();
    }
  }

  void _triggerErrorShake() {
    if (mounted) {
      _shakeController.reset();
      _shakeController.forward();
      HapticFeedback.mediumImpact(); // Haptic feedback for errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        color: ref.colors.background,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceL,
              vertical: DSTokens.spaceXL,
            ),
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value *
                        ((_shakeController.value * 2 - 1).abs() > 0.5 ? -1 : 1),
                    0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          (DSTokens.spaceXL * 2), // Account for padding
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: DSTokens.spaceL),

                            // Register Icon
                            const RegisterIcon(),

                            const SizedBox(height: DSTokens.spaceXL),

                            // Welcome Header
                            const WelcomeHeader(
                              title: 'Join Us Today',
                              subtitle: 'Create your account to get started',
                            ),

                            const SizedBox(height: DSTokens.spaceXXL),

                            // Full Name Field
                            AuthTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              prefixIcon: Icons.person_rounded,
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
                            AuthTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              prefixIcon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
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
                            AuthTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              prefixIcon: Icons.lock_rounded,
                              isPassword: true,
                              isPasswordVisible: _isPasswordVisible,
                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
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
                            AuthTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              prefixIcon: Icons.lock_rounded,
                              isPassword: true,
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
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

                            // Error Display
                            ErrorDisplay(
                              errorMessage: authState.error,
                              shakeController: _shakeController,
                            ),

                            // Register Button
                            AuthButton(
                              text: 'Create Account',
                              onPressed: _register,
                              isLoading: authState.isLoading,
                              backgroundColor: DSColors.success,
                            ),

                            const SizedBox(height: DSTokens.spaceL),

                            // Success Message for Account Creation
                            SuccessDisplay(
                              isVisible:
                                  authState.firebaseUser != null &&
                                  !authState.isVerified,
                              title: 'Account Created Successfully!',
                              message:
                                  'Your account has been created successfully. Please wait for an admin to verify your account before you can access all features.',
                            ),

                            // Progressive Auth Features - Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: DSTypography.bodySmall.copyWith(
                                    color: ref.colors.textSecondary,
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
                                  child: Text(
                                    'Sign In',
                                    style: DSTypography.link.copyWith(
                                      color: DSColors.success,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: DSTokens.spaceXL),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
