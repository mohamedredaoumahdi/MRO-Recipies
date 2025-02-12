import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';

class HomeContentNavBar extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeContentNavBar({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData _getTimeBasedIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return Icons.wb_sunny_outlined; // Morning sun
    } else if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny; // Afternoon full sun
    } else if (hour >= 17 && hour < 20) {
      return Icons.wb_twilight; // Evening sunset
    } else {
      return Icons.dark_mode_outlined; // Night moon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getTimeBasedIcon(), 
                    color: AppColors.primary, 
                    size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(_getGreeting(),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            FutureBuilder<String?>(
              future: _authService.getCurrentUsername(),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Guest',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
          ],
        ),
        // IconButton(
        //   icon: const Icon(Icons.shopping_cart_outlined),
        //   onPressed: () {},
        //   color: AppColors.textPrimary,
        // ),
      ],
    );
  }
}