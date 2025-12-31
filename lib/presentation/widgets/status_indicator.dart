import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/modbus_provider.dart';

/// Animated status indicator widget
class StatusIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final double size;

  const StatusIndicator({super.key, required this.status, this.size = 12});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.status == ConnectionStatus.connecting) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ConnectionStatus.connecting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return AppColors.connected;
      case ConnectionStatus.disconnected:
        return AppColors.disconnected;
      case ConnectionStatus.connecting:
        return AppColors.connecting;
      case ConnectionStatus.error:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return Icons.check_circle;
      case ConnectionStatus.disconnected:
        return Icons.circle_outlined;
      case ConnectionStatus.connecting:
        return Icons.sync;
      case ConnectionStatus.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(_animation.value),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5 * _animation.value),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Icon(_getStatusIcon(), color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          _getStatusText(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

