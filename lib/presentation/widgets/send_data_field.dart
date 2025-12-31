import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/hex_utils.dart';

/// Data from send field
class SendFieldData {
  final String text;
  final bool isHexMode;
  final String lineEnding;

  SendFieldData({
    required this.text,
    required this.isHexMode,
    required this.lineEnding,
  });
}

/// Reusable send data field with hex mode and line ending options
class SendDataField extends StatefulWidget {
  final int index;
  final bool isEnabled;
  final Function(SendFieldData)? onSend;

  const SendDataField({
    super.key,
    required this.index,
    this.isEnabled = true,
    this.onSend,
  });

  @override
  State<SendDataField> createState() => _SendDataFieldState();
}

class _SendDataFieldState extends State<SendDataField> {
  final TextEditingController _controller = TextEditingController();
  bool _isHexMode = false;
  String _lineEnding = 'None';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Validate hex if in hex mode
    if (_isHexMode && !HexUtils.isValidHex(text)) {
      _showError('Invalid hex format. Use: 48 65 6C 6C 6F');
      return;
    }

    // Call callback with data
    widget.onSend?.call(
      SendFieldData(text: text, isHexMode: _isHexMode, lineEnding: _lineEnding),
    );

    // Clear after send
    _controller.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: AppTheme.borderRadiusS,
        border: Border.all(color: AppColors.glassBorder.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.isEnabled,
                  style: AppTheme.bodyMedium.copyWith(
                    fontFamily: _isHexMode ? 'monospace' : null,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: _isHexMode ? '48 65...' : 'Message...',
                    hintStyle: AppTheme.bodySmall,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusS,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: widget.isEnabled ? (_) => _handleSend() : null,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppTheme.borderRadiusS,
                ),
                child: DropdownButton<String>(
                  value: _lineEnding,
                  items: AppStrings.lineEndingOptions.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e, style: AppTheme.labelSmall),
                    );
                  }).toList(),
                  onChanged: widget.isEnabled
                      ? (v) => setState(() => _lineEnding = v!)
                      : null,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 14),
                  isDense: true,
                  style: AppTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 32,
                width: 32,
                child: IconButton(
                  onPressed: widget.isEnabled ? _handleSend : null,
                  icon: const Icon(Icons.send, size: 16),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    disabledBackgroundColor: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: Checkbox(
                  value: _isHexMode,
                  onChanged: widget.isEnabled
                      ? (v) => setState(() => _isHexMode = v!)
                      : null,
                  activeColor: AppColors.primaryLight,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Hex',
                style: AppTheme.labelSmall.copyWith(
                  color: _isHexMode
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
