import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/presentation/providers/auth_provider.dart';
import '../../../design_system/design_system.dart';
import 'index.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isFirstTime = true;
  int _onboardingStep = 0; // Step-based onboarding
  final int _maxOnboardingSteps = 3;

  // Animation controllers for enhanced UX
  late AnimationController _shakeController;
  late AnimationController _loadingController;
  late AnimationController _onboardingController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;

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

    // Onboarding fade animation
    _onboardingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _onboardingController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start onboarding animation with a small delay
    if (_isFirstTime) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _onboardingController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    _onboardingController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _loadingController.repeat(); // Start loading animation

      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Stop loading animation only if widget is still mounted
      if (mounted && _loadingController.isAnimating) {
        _loadingController.stop();
      }

      // If login failed, trigger error animation
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

  void _nextOnboardingStep() {
    if (_onboardingStep < _maxOnboardingSteps - 1) {
      setState(() {
        _onboardingStep++;
      });
      HapticFeedback.selectionClick();
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    setState(() {
      _isFirstTime = false;
    });
    _onboardingController.reverse();
    HapticFeedback.mediumImpact();
  }

  Widget _getCurrentOnboardingStep() {
    final screenHeight = MediaQuery.of(context).size.height;

    switch (_onboardingStep) {
      case 0:
        return Positioned(
          top: screenHeight * 0.15,
          left: DSTokens.spaceL,
          right: DSTokens.spaceL,
          child: OnboardingTooltip(
            message:
                'Selamat Datang! 👋\n\nAplikasi ini memungkinkan Anda mengelola akun dan data secara offline. Mari mulai dengan masuk ke akun Anda.',
            onNext: _nextOnboardingStep,
            onSkip: _completeOnboarding,
            currentStep: 1,
            totalSteps: _maxOnboardingSteps,
          ),
        );
      case 1:
        return Positioned(
          top: screenHeight * 0.48,
          left: DSTokens.spaceL,
          right: DSTokens.spaceL,
          child: OnboardingTooltip(
            message:
                'Masukkan Email Anda ✉️\n\nKetikkan alamat email yang terdaftar untuk masuk dengan aman ke akun Anda.',
            onNext: _nextOnboardingStep,
            onSkip: _completeOnboarding,
            currentStep: 2,
            totalSteps: _maxOnboardingSteps,
          ),
        );
      case 2:
        return Positioned(
          bottom: screenHeight * 0.25,
          left: DSTokens.spaceL,
          right: DSTokens.spaceL,
          child: OnboardingTooltip(
            message:
                'Fitur Keamanan 🔒\n\nGunakan "Ingat Saya" untuk akses cepat, dan "Lupa Password?" jika perlu reset kata sandi.',
            onNext: _nextOnboardingStep,
            onSkip: _completeOnboarding,
            currentStep: 3,
            totalSteps: _maxOnboardingSteps,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main login content
          Container(
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
                            ((_shakeController.value * 2 - 1).abs() > 0.5
                                ? -1
                                : 1),
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
                                const SizedBox(
                                  height: DSTokens.spaceXL + DSTokens.spaceS,
                                ), // 40px
                                // Brand Icon
                                const BrandIcon(),

                                const SizedBox(height: DSTokens.spaceXL),

                                // Welcome Header
                                const WelcomeHeader(
                                  title: 'Welcome Back',
                                  subtitle: 'Sign in to your account',
                                ),

                                const SizedBox(height: DSTokens.spaceXXL),

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

                                // Remember Me & Forgot Password
                                RememberMeRow(
                                  rememberMe: _rememberMe,
                                  onRememberMeChanged: (value) {
                                    setState(() {
                                      _rememberMe = value;
                                    });
                                  },
                                  onForgotPasswordTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Forgot password feature coming soon!',
                                          style: DSTypography.bodyMedium
                                              .copyWith(
                                                color: DSColors.textOnColor,
                                              ),
                                        ),
                                        backgroundColor: DSColors.brandPrimary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            DSTokens.radiusM,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: DSTokens.spaceL),

                                // Error Display
                                ErrorDisplay(
                                  errorMessage: authState.error,
                                  shakeController: _shakeController,
                                ),

                                // Login Button
                                AuthButton(
                                  text: 'Sign In',
                                  onPressed: _login,
                                  isLoading: authState.isLoading,
                                ),

                                const SizedBox(height: DSTokens.spaceXL),

                                // Progressive Auth Features
                                ProgressiveAuthFeatures(
                                  showDivider: false,
                                  onCreateAccount: () {
                                    if (!authState.isLoading) {
                                      context.go('/register');
                                    }
                                  },
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
          // Onboarding Overlay
          if (_isFirstTime)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Tap to dismiss overlay (optional)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _completeOnboarding,
                          child: Container(color: Colors.transparent),
                        ),
                      ),

                      // Current step tooltip
                      _getCurrentOnboardingStep(),

                      // Skip button in top-right corner
                      Positioned(
                        top: DSTokens.spaceL,
                        right: DSTokens.spaceL,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: _completeOnboarding,
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            label: Text(
                              'Lewati',
                              style: DSTypography.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSTokens.spaceM,
                                vertical: DSTokens.spaceS,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
