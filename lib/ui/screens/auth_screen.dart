import 'package:flutter/material.dart';
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

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true; // State for password visibility
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _animationController.reset();
      _animationController.forward();
    });
  }

  // Toggle Password Visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Forgot Password Logic
  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter your email address to receive a password reset link.'),
                const SizedBox(height: 16),
                TextField(
                  controller: resetEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send Link'),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  // Basic validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an email address.')),
                  );
                  return;
                }
                
                Navigator.of(context).pop(); // Close dialog immediately

                try {
                  await _authService.sendPasswordResetEmail(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent! Check your inbox.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_isLogin) {
          // Normal Sign In
          await _authService.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          // AuthWrapper in main.dart handles navigation
        } else {
          // Sign Up with custom flow: Account Created -> Sign In Page
          await _authService.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          
          // Force sign out to prevent auto-login
          await _authService.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please sign in.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Switch to Login Mode
            setState(() {
              _isLogin = true;
              _passwordController.clear(); // Clear password for security
              _isLoading = false;
            });
            return; // Exit early to avoid finally block resetting loading too fast
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim(); // Clean Firebase error
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
      body: Stack(
        children: [
          // Decorative Top Curve
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline_rounded, size: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Join Spikeman Inc.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isLogin ? 'Sign in to your account' : 'Connect with professionals',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Form Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              hintText: 'name@example.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: '••••••••',
                              obscureText: _obscurePassword,
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              validator: Validators.validatePassword,
                            ),
                            
                            // Forgot Password Link (Only in Login Mode)
                            if (_isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else 
                              const SizedBox(height: 10), // Spacing for signup

                            if (!_isLogin)
                                const SizedBox(height: 20),

                            PrimaryButton(
                              text: _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                              isLoading: _isLoading,
                              onPressed: _submitForm,
                            ),
                            
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLogin ? "New here? " : "Already have an account? ",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: _toggleFormMode,
                                  child: Text(
                                    _isLogin ? "Sign Up" : "Sign In",
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
