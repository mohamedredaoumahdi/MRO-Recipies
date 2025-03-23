import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/screens/search_screen.dart';
import 'package:moroccan_recipies_app/screens/profile_screen.dart';

class HomeAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onSearchTap;
  final String? avatarUrl;

  const HomeAppBar({
    Key? key,
    required this.scrollController,
    required this.onSearchTap,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _showElevation = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowElevation = widget.scrollController.offset > 0;
    if (shouldShowElevation != _showElevation) {
      setState(() {
        _showElevation = shouldShowElevation;
      });
    }
  }

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: _showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getTimeBasedIcon(), color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<String?>(
                            future: _authService.getCurrentUsername(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Guest',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildSearchButton(),
                        const SizedBox(width: 12),
                        _buildProfileAvatar(),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Search bar - optional for expanded view
                AnimatedOpacity(
                  opacity: _showElevation ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: widget.onSearchTap,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search Moroccan recipes...',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.search, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        // Navigate to profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(onBack: () {
              Navigator.pop(context);
            }),
          ),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: widget.avatarUrl != null
            ? NetworkImage(widget.avatarUrl!)
            : null,
        child: widget.avatarUrl == null
            ? Icon(
                Icons.person,
                size: 20,
                color: AppColors.primary,
              )
            : null,
      ),
    );
  }
}