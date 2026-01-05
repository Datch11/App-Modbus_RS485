import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/modbus_provider.dart';

/// Dedicated widget for slave address input field
/// Manages TextEditingController lifecycle properly to prevent memory leaks
class SlaveAddressField extends StatefulWidget {
  const SlaveAddressField({super.key});

  @override
  State<SlaveAddressField> createState() => _SlaveAddressFieldState();
}

class _SlaveAddressFieldState extends State<SlaveAddressField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ModbusProvider>();
    _controller = TextEditingController(text: provider.slaveAddress.toString());
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        // Only update text if provider value changed and field is not focused
        // This prevents losing cursor position while typing
        if (!_controller.selection.isValid ||
            !_controller.selection.isCollapsed) {
          final currentValue = provider.slaveAddress.toString();
          if (_controller.text != currentValue) {
            _controller.text = currentValue;
          }
        }

        return SizedBox(
          width: 80,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: AppTheme.borderRadiusM,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingS,
              ),
            ),
            onChanged: (value) {
              final address = int.tryParse(value);
              if (address != null && address >= 1 && address <= 247) {
                provider.setSlaveAddress(address);
              }
            },
          ),
        );
      },
    );
  }
}
