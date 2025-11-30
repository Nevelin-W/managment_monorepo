import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';
import '../common/themed_text_field.dart';
import '../common/gradient_button.dart';
import '../common/info_box.dart';

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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    await _authService.signup(email, password, name);

    if (!mounted) return;

    // Use query parameters (RECOMMENDED)
    context.go('/email-verification?email=${Uri.encodeComponent(email)}');
    
    // OR if you prefer to use extra (less reliable on web):
    // context.go('/email-verification', extra: {'email': email});

  } catch (e) {
    if (!mounted) return;
    
    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.themeColors.surface.withValues(alpha: 0.6),
            widget.themeColors.background.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.themeColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(),
                const SizedBox(height: 32),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
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
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to get started',
          style: TextStyle(
            color: widget.themeColors.primary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                widget.themeColors.primary.withValues(alpha: 0.5),
                widget.themeColors.secondary.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return ThemedTextField(
      controller: _nameController,
      themeColors: widget.themeColors,
      labelText: 'Full Name',
      prefixIcon: Icons.person_outlined,
      enabled: !_isLoading,
      validator: (value) => value == null || value.isEmpty
          ? 'Please enter your name'
          : null,
    );
  }

  Widget _buildEmailField() {
    return ThemedTextField(
      controller: _emailController,
      themeColors: widget.themeColors,
      labelText: 'Email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isLoading,
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return ThemedTextField(
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
    );
  }

  Widget _buildConfirmPasswordField() {
    return ThemedTextField(
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
    );
  }

  Widget _buildSignUpButton() {
    return GradientButton(
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
    );
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
}