import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Custom gradient button widget
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.isOutlined = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final buttonColor = widget.color ?? AppColors.primaryLight;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        curve: AppTheme.curveSmooth,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: isEnabled
                        ? [buttonColor, buttonColor.withOpacity(0.8)]
                        : [AppColors.textDisabled, AppColors.textDisabled],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.isOutlined ? Colors.transparent : null,
            border: widget.isOutlined
                ? Border.all(color: buttonColor, width: 2)
                : null,
            borderRadius: AppTheme.borderRadiusM,
            boxShadow: isEnabled && !widget.isOutlined
                ? AppTheme.shadowMedium
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isOutlined ? buttonColor : Colors.white,
                    ),
                  ),
                )
              else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isOutlined ? buttonColor : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
              ],
              Text(
                widget.text,
                style: AppTheme.labelLarge.copyWith(
                  color: widget.isOutlined ? buttonColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
