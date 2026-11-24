import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/animations/fade_slide_in.dart';
import '../../../core/illustrations/kid_scenes.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../blocs/auth_cubit.dart';
import '../../main_nav/main_nav_screen.dart';
import '../widgets/auth_text_field.dart';
import 'signup_screen.dart';

enum AuthInputType { phone, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  AuthInputType _inputType = AuthInputType.phone;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    AppAudioService.instance.playTapSound();

    final cubit = context.read<AuthCubit>();
    if (_inputType == AuthInputType.phone) {
      cubit.loginWithPhone(
        _phoneController.text.trim(),
        _passwordController.text,
      );
    } else {
      cubit.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _fillDemoCredentials() {
    AppAudioService.instance.playTapSound();
    setState(() {
      _inputType = AuthInputType.phone;
      _phoneController.text = '9876543210';
      _passwordController.text = 'password123';
    });
  }

  void _showForgotPasswordDialog() {
    AppAudioService.instance.playTapSound();
    final resetController = TextEditingController(
      text: _inputType == AuthInputType.phone
          ? _phoneController.text
          : _emailController.text,
    );
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            Text('Reset Password', style: AppTextStyles.heading3()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered ${_inputType == AuthInputType.phone ? "Mobile Number" : "Email"} and new password:',
              style: AppTextStyles.bodySmall(color: AppColors.textMedium),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetController,
              keyboardType: _inputType == AuthInputType.phone
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _inputType == AuthInputType.phone ? 'Mobile (10 digits)' : 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password (min 6 chars)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final newPass = newPassController.text;
              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              final success = await context.read<AuthCubit>().resetPassword(
                phone: _inputType == AuthInputType.phone ? resetController.text : null,
                email: _inputType == AuthInputType.email ? resetController.text : null,
                newPassword: newPass,
              );
              if (ctx.mounted && mounted) {
                Navigator.of(ctx).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully! Please log in.'),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          AppAudioService.instance.playSuccessChime();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          AppAudioService.instance.playIncorrectSound();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Mascot Hero Scene
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: ReadingHeroScene(size: 140),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back! 👋',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading1(color: AppColors.primaryPurple),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Log in to track your kid\'s stars & learning progress',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Segmented Switcher: Mobile Number vs Email
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSegmentButton(
                              label: '📱 Mobile Number',
                              isSelected: _inputType == AuthInputType.phone,
                              onTap: () {
                                AppAudioService.instance.playTapSound();
                                setState(() => _inputType = AuthInputType.phone);
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildSegmentButton(
                              label: '✉️ Email Address',
                              isSelected: _inputType == AuthInputType.email,
                              onTap: () {
                                AppAudioService.instance.playTapSound();
                                setState(() => _inputType = AuthInputType.email);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Fields
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 250),
                    child: Column(
                      children: [
                        if (_inputType == AuthInputType.phone)
                          AuthTextField(
                            controller: _phoneController,
                            label: 'Parent Mobile Number',
                            hintText: 'e.g. 9876543210',
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            prefix: Container(
                              margin: const EdgeInsets.only(right: 10, left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🇮🇳 +91',
                                style: AppTextStyles.buttonSmall(
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.phone_android_rounded,
                              color: AppColors.primaryPurple,
                            ),
                            validator: AuthValidators.validatePhone,
                          )
                        else
                          AuthTextField(
                            controller: _emailController,
                            label: 'Parent Email Address',
                            hintText: 'parent@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryPurple,
                            ),
                            validator: AuthValidators.validateEmail,
                          ),
                        const SizedBox(height: 16),

                        // Password Field
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter 6+ characters',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primaryPurple,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textMedium,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: AuthValidators.validatePassword,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password & Quick Demo Fill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _fillDemoCredentials,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: Text(
                          '⚡ Quick Demo Fill',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.primaryPurple,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Login CTA Button
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return AppButton(
                          label: isLoading ? 'Logging in...' : 'Login to LearnWithFun 🚀',
                          width: double.infinity,
                          height: 54,
                          onPressed: isLoading ? null : _onLogin,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Continue as Guest Option
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.explore_rounded,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                        label: Text(
                          'Continue as Guest Explorer 🎈',
                          style: AppTextStyles.buttonSmall(color: AppColors.primaryPurple),
                        ),
                        onPressed: () {
                          AppAudioService.instance.playTapSound();
                          context.read<AuthCubit>().continueAsGuest();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainNavScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppAudioService.instance.playTapSound();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            'Sign Up Now',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.primaryPurple,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primaryPurple : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }
}
