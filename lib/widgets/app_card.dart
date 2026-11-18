import 'package:cloud_car/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.borderRadius = 20,
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppTheme.cyan;

    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: color.withOpacity(0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: AppTheme.cardGradient(color),
          ),
          child: child,
        ),
      ),
    );
  }
}
