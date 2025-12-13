import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/common/info_box.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/theme.dart';
import '../../../core/widgets/form/themed_text_field.dart';
import '../../../core/widgets/common/gradient_button.dart';
import '../../../features/auth/widgets/form_container.dart';
import '../../../features/auth/widgets/form_header.dart';

class SignupForm extends StatefulWidget {
  final ThemeColors themeColors;

  const SignupForm({
    super.key,
    required this.themeColors,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _autoValidate = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _autoValidate = true);
    
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signup(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (!mounted) return;

      context.go('/email-verification?email=${Uri.encodeComponent(_emailController.text.trim())}');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      themeColors: widget.themeColors,
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeader(
              themeColors: widget.themeColors,
              title: 'Create Account',
              subtitle: 'Sign up to get started',
            ),
            const SizedBox(height: 32),
            ThemedTextField(
              controller: _nameController,
              themeColors: widget.themeColors,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outlined,
              enabled: !_isLoading,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 16),
            ThemedTextField(
              controller: _emailController,
              themeColors: widget.themeColors,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            ThemedTextField(
              controller: _passwordController,
              themeColors: widget.themeColors,
              labelText: 'Password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              validator: _validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: widget.themeColors.primary.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            const SizedBox(height: 16),
            ThemedTextField(
              controller: _confirmPasswordController,
              themeColors: widget.themeColors,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              enabled: !_isLoading,
              validator: _validateConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignup(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: widget.themeColors.primary.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            const SizedBox(height: 12),
            InfoBox(
              themeColors: widget.themeColors,
              icon: Icons.info_outline,
              message: '8+ chars, uppercase, lowercase, number',
              type: InfoBoxType.info,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              InfoBox(
                themeColors: widget.themeColors,
                icon: Icons.error_outline,
                message: _errorMessage!,
                type: InfoBoxType.error,
              ),
            ],
            const SizedBox(height: 32),
            GradientButton(
              onPressed: _isLoading ? null : _handleSignup,
              isLoading: _isLoading,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.themeColors.primary,
                  widget.themeColors.secondary,
                  widget.themeColors.tertiary,
                ],
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}