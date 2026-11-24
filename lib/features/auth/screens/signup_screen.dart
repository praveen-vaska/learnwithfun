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
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  AuthInputType _inputType = AuthInputType.phone;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    AppAudioService.instance.playTapSound();

    final cubit = context.read<AuthCubit>();
    cubit.register(
      name: _nameController.text.trim(),
      phone: _inputType == AuthInputType.phone ? _phoneController.text.trim() : null,
      email: _inputType == AuthInputType.email ? _emailController.text.trim() : null,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          AppAudioService.instance.playSuccessChime();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Account created successfully! Welcome!'),
              backgroundColor: AppColors.green,
            ),
          );
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Create Account', style: AppTextStyles.heading2()),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mascot Header
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: TrophyScene(size: 110, confetti: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: Column(
                      children: [
                        Text(
                          'Join Learn With Fun! 🚀',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading2(color: AppColors.primaryPurple),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Save progress, quiz scores, and stars across devices',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 18),

                  // Fields
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 250),
                    child: Column(
                      children: [
                        // Full Name
                        AuthTextField(
                          controller: _nameController,
                          label: 'Parent / Child Name',
                          hintText: 'e.g. Rahul Sharma',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryPurple,
                          ),
                          validator: AuthValidators.validateName,
                        ),
                        const SizedBox(height: 14),

                        // Phone or Email
                        if (_inputType == AuthInputType.phone)
                          AuthTextField(
                            controller: _phoneController,
                            label: 'Mobile Number',
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
                            label: 'Email Address',
                            hintText: 'parent@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryPurple,
                            ),
                            validator: AuthValidators.validateEmail,
                          ),
                        const SizedBox(height: 14),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Create 6+ character password',
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
                        const SizedBox(height: 14),

                        // Confirm Password
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppColors.primaryPurple,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textMedium,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                          validator: (val) => AuthValidators.validateConfirmPassword(
                            val,
                            _passwordController.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Create Account CTA
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return AppButton(
                          label: isLoading ? 'Creating Account...' : 'Create Account 🎉',
                          width: double.infinity,
                          height: 54,
                          onPressed: isLoading ? null : _onSignUp,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have account
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppAudioService.instance.playTapSound();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Login Here',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.primaryPurple,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
