import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

/// A decorative divider with Moroccan-inspired design
class MoroccanDivider extends StatelessWidget {
  final double height;
  final Color color;
  
  const MoroccanDivider({
    Key? key, 
    this.height = 24, 
    this.color = AppColors.primary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Icon(
              Icons.auto_awesome,
              size: height * 0.8,
              color: color,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

/// A pattern-based divider with alternating elements
class MoroccanPatternDivider extends StatelessWidget {
  final Color color;
  
  const MoroccanPatternDivider({
    Key? key,
    this.color = AppColors.primary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: List.generate(
          9,
          (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A container with Moroccan arch-style decoration at the top
class MoroccanArchDecoration extends StatelessWidget {
  final Widget child;
  final Color color;
  
  const MoroccanArchDecoration({
    Key? key,
    required this.child,
    this.color = Colors.white,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipPath(
            clipper: ArchClipper(),
            child: Container(
              height: 20,
              color: color,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Clipper for Moroccan-style arches
class ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    
    // Create multiple arches
    final archWidth = size.width / 7;
    for (int i = 0; i < 7; i++) {
      path.relativeQuadraticBezierTo(
        archWidth / 2, -size.height,
        archWidth, 0,
      );
    }
    
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// A custom information card for displaying recipe metadata
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated recipe card that scales slightly on hover/tap
class AnimatedRecipeCard extends StatefulWidget {
  final Widget child;
  final Function()? onTap;

  const AnimatedRecipeCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  _AnimatedRecipeCardState createState() => _AnimatedRecipeCardState();
}

class _AnimatedRecipeCardState extends State<AnimatedRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: _isHovered ? 12 : 6,
                      offset: Offset(0, _isHovered ? 6 : 3),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Creates a custom page route transition
Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// Helper functions for recipe difficulty colors
Color getDifficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return AppColors.accent3;
    case 'medium':
      return AppColors.accent2;
    case 'hard':
      return AppColors.primary;
    default:
      return AppColors.accent3;
  }
}

/// Helper function for recipe difficulty icons
IconData getDifficultyIcon(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return Icons.sentiment_satisfied;
    case 'medium':
      return Icons.sentiment_neutral;
    case 'hard':
      return Icons.sentiment_dissatisfied;
    default:
      return Icons.sentiment_satisfied;
  }
}