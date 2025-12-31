import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Glass-morphism card widget
class ConnectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ConnectionCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
        decoration: AppTheme.glassDecoration,
        child: child,
      ),
    );
  }
}
