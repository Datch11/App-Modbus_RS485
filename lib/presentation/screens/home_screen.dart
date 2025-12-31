import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/data_display_mode.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/hex_utils.dart';
import '../../data/models/message_history.dart';
import '../../providers/modbus_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/connection_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/send_data_field.dart';
import 'connection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildMessageInput(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildMessageHistory(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom app bar with glassmorphism
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppTheme.borderRadiusM,
            ),
            child: const Icon(
              Icons.electrical_services,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName, style: AppTheme.headlineMedium),
              Text(AppStrings.appDescription, style: AppTheme.bodySmall),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            color: AppColors.textPrimary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  /// Build connection status card
  Widget _buildStatusCard() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        return ConnectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.connectionStatus, style: AppTheme.labelMedium),
              const SizedBox(height: AppTheme.spacingM),
              StatusIndicator(status: provider.status),
              const SizedBox(height: AppTheme.spacingM),
              if (provider.selectedPort != null) ...[
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppTheme.spacingM),
                _buildInfoRow('Port', provider.selectedPort ?? 'Unknown'),
                _buildInfoRow('Baud Rate', '${provider.baudRate}'),
                _buildInfoRow('Slave Address', '${provider.slaveAddress}'),
                _buildInfoRow(
                  'Port Config',
                  '${provider.dataBits}${provider.parity[0]}${provider.stopBits}',
                ),
              ],
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: provider.isConnected
                          ? AppStrings.disconnect
                          : AppStrings.connect,
                      icon: provider.isConnected ? Icons.link_off : Icons.link,
                      onPressed: provider.isConnected
                          ? () => provider.disconnect()
                          : () => _navigateToConnection(context),
                      color: provider.isConnected
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0);
      },
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build message input section
  Widget _buildMessageInput() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        return ConnectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Send Data', style: AppTheme.headlineSmall),
              const SizedBox(height: AppTheme.spacingS),
              // Error message if exists
              if (provider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusS,
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: AppTheme.labelSmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
              // 3 Send fields with hex support
              SendDataField(
                index: 0,
                isEnabled: provider.isConnected && !provider.isLoading,
                onSend: (data) => _handleFieldSend(provider, data),
              ),
              SendDataField(
                index: 1,
                isEnabled: provider.isConnected && !provider.isLoading,
                onSend: (data) => _handleFieldSend(provider, data),
              ),
              SendDataField(
                index: 2,
                isEnabled: provider.isConnected && !provider.isLoading,
                onSend: (data) => _handleFieldSend(provider, data),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
      },
    );
  }

  /// Build message history
  Widget _buildMessageHistory() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        if (provider.messageHistory.isEmpty) {
          return ConnectionCard(
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'No messages yet',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.messageHistory, style: AppTheme.headlineSmall),
                Row(
                  children: [
                    // Display mode toggle buttons
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppTheme.borderRadiusM,
                      ),
                      child: Row(
                        children: [
                          _buildModeButton(
                            provider,
                            AppStrings.displayModeAscii,
                            DataDisplayMode.ascii,
                            Icons.text_fields,
                          ),
                          _buildModeButton(
                            provider,
                            AppStrings.displayModeHex,
                            DataDisplayMode.hex,
                            Icons.code,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    // Export button
                    IconButton(
                      onPressed: () => _exportData(provider),
                      icon: const Icon(Icons.download, size: 18),
                      tooltip: AppStrings.btnExport,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.all(AppTheme.spacingS),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Scrollable message log
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppTheme.borderRadiusM,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                itemCount: provider.messageHistory.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final message =
                      provider.messageHistory[provider.messageHistory.length -
                          1 -
                          index];
                  return _buildMessageItem(message, provider);
                },
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  /// Build mode toggle button
  Widget _buildModeButton(
    ModbusProvider provider,
    String label,
    DataDisplayMode mode,
    IconData icon,
  ) {
    final isSelected = provider.displayMode == mode;
    return InkWell(
      onTap: () => provider.setDisplayMode(mode),
      borderRadius: AppTheme.borderRadiusM,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: AppTheme.borderRadiusM,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual message item
  Widget _buildMessageItem(MessageHistory message, ModbusProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ConnectionCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                gradient: message.isSent
                    ? AppColors.primaryGradient
                    : (message.isSuccess
                          ? AppColors.successGradient
                          : AppColors.errorGradient),
                borderRadius: AppTheme.borderRadiusM,
              ),
              child: Icon(
                message.isSent ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text - format based on display mode
                  Text(
                    _getFormattedMessage(message, provider.displayMode),
                    style: AppTheme.bodyMedium.copyWith(
                      fontFamily: provider.displayMode == DataDisplayMode.hex
                          ? 'monospace'
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Row(
                    children: [
                      Text(message.formattedTime, style: AppTheme.labelSmall),
                      const SizedBox(width: AppTheme.spacingS),
                      Icon(
                        message.isSuccess ? Icons.check_circle : Icons.error,
                        size: 12,
                        color: message.isSuccess
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                  if (!message.isSuccess && message.errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      message.errorMessage!,
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  /// Get formatted message based on display mode
  String _getFormattedMessage(MessageHistory message, DataDisplayMode mode) {
    if (mode == DataDisplayMode.hex && message.hasRawBytes) {
      // Display as HEX
      return HexUtils.bytesToHex(message.rawBytes!);
    }
    // Display as ASCII (default)
    return message.message;
  }

  /// Handle send from any field
  void _handleFieldSend(ModbusProvider provider, SendFieldData data) {
    if (data.isHexMode) {
      // Send as hex bytes
      try {
        final bytes = HexUtils.hexToBytes(data.text);
        provider.sendMessageWithBytes(
          bytes: bytes,
          displayText: data.text,
          lineEnding: data.lineEnding,
        );
      } catch (e) {
        // Error already shown by SendDataField widget
      }
    } else {
      // Send as text (via Modbus protocol)
      provider.sendMessage(data.text);
    }
  }

  /// Export data to text format
  void _exportData(ModbusProvider provider) {
    if (provider.messageHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Modbus RS485 Communication Log ===');
    buffer.writeln('Exported: ${DateTime.now()}');
    buffer.writeln('Total messages: ${provider.messageHistory.length}');
    buffer.writeln('${'=' * 40}\n');

    for (final msg in provider.messageHistory.reversed) {
      final direction = msg.isSent ? 'SENT' : 'RECV';
      final status = msg.isSuccess ? 'OK' : 'FAIL';
      buffer.writeln('[$direction] ${msg.formattedTime} [$status]');
      buffer.writeln('  ${msg.message}');
      if (msg.hasRawBytes) {
        buffer.writeln('  HEX: ${HexUtils.bytesToHex(msg.rawBytes!)}');
      }
      if (msg.errorMessage != null) {
        buffer.writeln('  ERROR: ${msg.errorMessage}');
      }
      buffer.writeln();
    }

    // Show export ready notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export ready (${provider.messageHistory.length} messages)',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Export Data'),
                content: SingleChildScrollView(
                  child: SelectableText(
                    buffer.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Navigate to connection screen
  void _navigateToConnection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConnectionScreen()),
    );
  }
}
