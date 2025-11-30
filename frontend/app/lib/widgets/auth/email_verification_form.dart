import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';
import '../common/gradient_button.dart';
import '../common/info_box.dart';

class EmailVerificationForm extends StatefulWidget {
  final ThemeColors themeColors;
  final String email;

  const EmailVerificationForm({
    super.key,
    required this.themeColors,
    required this.email,
  });

  @override
  State<EmailVerificationForm> createState() => _EmailVerificationFormState();
}

class _EmailVerificationFormState extends State<EmailVerificationForm> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

Future<void> _verifyCode() async {
  final code = _getCode();
  
  if (code.length != 6) {
    setState(() => _errorMessage = 'Please enter all 6 digits');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
  });

  try {
    // Explicitly await and assign to ensure proper Future completion
    await _authService.confirmEmail(widget.email, code).then((_) {});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email verified successfully!'),
        backgroundColor: widget.themeColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    context.go('/login');
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _errorMessage = e.toString().contains('Exception: ')
          ? e.toString().replaceAll('Exception: ', '')
          : e.toString();
      _isLoading = false;
    });
    _clearCode();
  }
}

Future<void> _resendCode() async {
  setState(() {
    _isResending = true;
    _errorMessage = null;
    _successMessage = null;
  });

  try {
    await _authService.resendCode(widget.email).then((_) {});

    if (!mounted) return;

    setState(() {
      _successMessage = 'Verification code resent! Check your email.';
      _isResending = false;
    });
    _clearCode();
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isResending = false;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle(),
              const SizedBox(height: 32),
              _buildCodeInput(),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                InfoBox(
                  themeColors: widget.themeColors,
                  icon: Icons.error_outline,
                  message: _errorMessage!,
                  type: InfoBoxType.error,
                ),
              if (_successMessage != null)
                InfoBox(
                  themeColors: widget.themeColors,
                  icon: Icons.check_circle_outline,
                  message: _successMessage!,
                  type: InfoBoxType.success,
                ),
              if (_errorMessage != null || _successMessage != null)
                const SizedBox(height: 24),
              _buildVerifyButton(),
              const SizedBox(height: 20),
              _buildResendSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Verify Your Email',
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
          'Enter the 6-digit code sent to',
          style: TextStyle(
            color: widget.themeColors.primary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: TextStyle(
            color: widget.themeColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildDigitBox(index),
        );
      }),
    );
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !_isLoading,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: widget.themeColors.background.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.themeColors.primary.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.themeColors.primary.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.themeColors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          if (value.length > 1) {
            final pastedText = value;
            _handlePaste(pastedText, index);
            return;
          }
          
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyCode();
            }
          }
        },
        onTap: () {
          for (int i = 0; i < index; i++) {
            if (_controllers[i].text.isEmpty) {
              _focusNodes[i].requestFocus();
              return;
            }
          }
        },
      ),
    );
  }

  void _handlePaste(String pastedText, int startIndex) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    
    for (int i = 0; i < digits.length && (startIndex + i) < 6; i++) {
      _controllers[startIndex + i].text = digits[i];
    }
    
    final nextEmptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    if (nextEmptyIndex != -1) {
      _focusNodes[nextEmptyIndex].requestFocus();
    } else {
      _focusNodes[5].unfocus();
      _verifyCode();
    }
  }

  Widget _buildVerifyButton() {
    return GradientButton(
      onPressed: _isLoading ? null : _verifyCode,
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
        'Verify Email',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.themeColors.primary.withValues(alpha: 0.1),
            widget.themeColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't receive a code? ",
            style: TextStyle(
              color: widget.themeColors.primary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          if (_isResending)
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.themeColors.primary,
                ),
              ),
            )
          else
            InkWell(
              onTap: _resendCode,
              child: Text(
                'Resend',
                style: TextStyle(
                  color: widget.themeColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: widget.themeColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}