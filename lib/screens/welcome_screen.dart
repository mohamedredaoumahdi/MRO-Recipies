import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/screens/register_screen.dart';
import 'package:moroccan_recipies_app/screens/signIn_screen.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                    onPressed: () {
                      // TODO: Handle skip action
                    },
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
              ),
              const Expanded(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Help your path to health\ngoals with happiness',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.textLight,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to login screen
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Create New Account',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}