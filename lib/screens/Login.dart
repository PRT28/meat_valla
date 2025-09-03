import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'Register.dart';
import 'Base.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if user exists first
      final userExists = await authProvider.checkUserExists(_phoneController.text.trim());

      if (!userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this phone number. Please register first.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final success = await authProvider.sendOtpForLogin(
        phoneNumber: _phoneController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOtp(
      phoneNumber: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
      isRegistration: false,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BaseScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.sendOtpForLogin(
      phoneNumber: _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        _isOtpSent ? 'Verify OTP' : 'Welcome Back!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOtpSent
                            ? 'Enter the OTP sent to ${_phoneController.text}'
                            : 'Login to your Meat Valla account',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                if (!_isOtpSent) ...[
                  // Phone Number Field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // OTP Field
                  CustomTextField(
                    controller: _otpController,
                    label: 'Enter OTP',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.security_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Resend OTP
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),

                // Login/Verify Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                      isLoading: authProvider.isLoading,
                      child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
                    );
                  },
                ),

                if (_isOtpSent) ...[
                  const SizedBox(height: 16),

                  // Back to Phone Number
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text(
                      'Change Phone Number',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}