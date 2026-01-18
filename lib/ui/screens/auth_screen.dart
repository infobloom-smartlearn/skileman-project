import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_isLogin) {
          await _authService.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await _authService.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }
        // Navigation is usually handled by the StreamBuilder in main.dart
        // listening to auth state changes.
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Sign in to continue to Spikeman Inc.'
                        : 'Join Spikeman Inc. today',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.errorRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: '••••••',
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: _isLogin ? 'Sign In' : 'Sign Up',
                    isLoading: _isLoading,
                    onPressed: _submitForm,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(color: AppColors.textDark),
                      ),
                      TextButton(
                        onPressed: _toggleFormMode,
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
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
      ),
    );
  }
}
