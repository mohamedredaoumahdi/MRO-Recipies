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
          const Expanded(
            flex: 2,
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees in radians
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Divider(color: color),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(
              Icons.star,
              size: height * 0.7,
              color: color,
            ),
          ),
          Expanded(
            flex: 1,
            child: Divider(color: color),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees in radians
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Divider(),
          ),
        ],
      ),
    );
  }
}

/// A pattern-based divider with alternating elements inspired by Moroccan tiles
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
class MoroccanArchContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color archColor;
  final double height;
  
  const MoroccanArchContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.archColor = AppColors.primary,
    this.height = 200,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
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
            clipper: MoroccanArchClipper(),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: archColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Clipper for Moroccan-style arches
class MoroccanArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    
    // Create 5 arches
    final archCount = 5;
    final archWidth = size.width / archCount;
    
    for (int i = 0; i < archCount; i++) {
      path.relativeQuadraticBezierTo(
        archWidth / 2, -size.height * 0.8,
        archWidth, 0,
      );
    }
    
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// A custom decoration painter for Moroccan pattern backgrounds
class MoroccanPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  
  MoroccanPatternPainter({
    this.color = AppColors.primary,
    this.opacity = 0.1,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final patternSize = 30.0;
    final horizontalCount = (size.width / patternSize).ceil() + 1;
    final verticalCount = (size.height / patternSize).ceil() + 1;
    
    // Draw vertical and horizontal lines first
    for (int i = 0; i < horizontalCount; i++) {
      final x = i * patternSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (int i = 0; i < verticalCount; i++) {
      final y = i * patternSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw diagonal lines
    for (int i = 0; i < horizontalCount + verticalCount; i++) {
      final startX = i * patternSize;
      final startY = 0.0;
      
      final endX = 0.0;
      final endY = i * patternSize;
      
      if (startX <= size.width) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX > size.width ? size.width : startX, startY + (startX > size.width ? (startX - size.width) : 0)),
          paint,
        );
      }
      
      if (endY <= size.height && i > 0) {
        canvas.drawLine(
          Offset(endX, endY),
          Offset(endX + (endY > size.height ? (endY - size.height) : 0), endY > size.height ? size.height : endY),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A card with Moroccan-inspired decoration
class MoroccanCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  
  const MoroccanCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.primary,
    this.elevation = 2,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

/// A button styled with Moroccan design elements
class MoroccanButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double height;
  final double borderRadius;
  
  const MoroccanButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = AppColors.primary,
    this.height = 48,
    this.borderRadius = 12,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 4,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(double.infinity, height),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative patterns as background
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CustomPaint(
              painter: MoroccanPatternPainter(
                color: Colors.white,
                opacity: 0.1,
              ),
              child: Container(
                height: height,
                width: double.infinity,
              ),
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}

/// Creates a custom page route transition with Moroccan flair
Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: fadeAnimation,
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
      return AppColors.success;
    case 'medium':
      return AppColors.warning;
    case 'hard':
      return AppColors.error;
    default:
      return AppColors.success;
  }
}

/// Helper function for recipe difficulty icons
IconData getDifficultyIcon(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return Icons.sentiment_satisfied_alt;
    case 'medium':
      return Icons.sentiment_neutral;
    case 'hard':
      return Icons.sentiment_dissatisfied;
    default:
      return Icons.sentiment_satisfied_alt;
  }
}