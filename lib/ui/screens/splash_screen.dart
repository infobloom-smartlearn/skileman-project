import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Check if widget is still mounted before navigating
      if (mounted) {
        // We will delegate actual routing decision to a Wrapper in main.dart
        // But per requirements "Automatically navigates to Authentication screen"
        // I'll assume we navigate to the wrapper or AuthScreen directly if not redundant.
        // For better UX during dev (if no auth wrapper in main yet), we replace with AuthScreen.
        // However, standard practice is to let main's StreamBuilder handle it.
        // But to strictly follow "Splash Screen -> Automatically navigates", I will pushReplacement.
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_outline_rounded, // Simple placeholder logo
              size: 80,
              color: AppColors.white,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary wrapper to decide where to go, or we can just go to AuthScreen
// The prompt asks for "Splash Screen -> Authentication Screen". 
// But a real app usually checks if user is logged in.
// I will direct to AuthScreen as requested, but `AuthScreen` can handle the "already logged in" case 
// or main.dart can. I'll stick to a simple AuthWrapper here or in main.
// For now, let's just make sure AuthWrapper is defined somewhere or imported.
// Actually, I'll put AuthWrapper in main.dart to be cleaner.
// So here I will just navigate to 'Wrapper' or 'AuthScreen'.
// Let's navigate to a named route '/' or just AuthScreen for simplicity as asked.
