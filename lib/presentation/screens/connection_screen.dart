import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/modbus_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/connection_card.dart';

/// Connection configuration screen
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-scan ports on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModbusProvider>().scanPorts();
    });
  }

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
                      _buildPortSelector(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildConnectionSettings(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildConnectButton(),
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

  /// Build app bar
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Text(AppStrings.connectionTitle, style: AppTheme.headlineMedium),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Build port selector
  Widget _buildPortSelector() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        return ConnectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Serial Port', style: AppTheme.headlineSmall),
                  IconButton(
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    color: AppColors.primaryLight,
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.scanPorts(),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (provider.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Scanning serial ports...',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider.availablePorts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppTheme.borderRadiusM,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.usb_off,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'No serial ports found',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...provider.availablePorts.map(
                  (port) => _buildPortItem(port, provider),
                ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0);
      },
    );
  }

  /// Build port item
  Widget _buildPortItem(String port, ModbusProvider provider) {
    final isSelected = provider.selectedPort == port;

    return GestureDetector(
      onTap: () => provider.selectPort(port),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: AppTheme.borderRadiusM,
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [AppColors.surface, AppColors.surface],
                      ),
                borderRadius: AppTheme.borderRadiusM,
              ),
              child: Icon(
                Icons.usb,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    port,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'Serial Port',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0),
    );
  }

  /// Build connection settings
  Widget _buildConnectionSettings() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        return ConnectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Connection Settings', style: AppTheme.headlineSmall),
              const SizedBox(height: AppTheme.spacingM),

              // Baud Rate
              _buildSettingRow(
                label: AppStrings.baudRate,
                child: DropdownButton<int>(
                  value: provider.baudRate,
                  dropdownColor: AppColors.surface,
                  style: AppTheme.bodyMedium,
                  underline: Container(),
                  items: AppStrings.baudRateOptions.map((rate) {
                    return DropdownMenuItem(value: rate, child: Text('$rate'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setBaudRate(value);
                  },
                ),
              ),

              const Divider(color: AppColors.divider),

              // Data Bits
              _buildSettingRow(
                label: 'Data Bits',
                child: DropdownButton<int>(
                  value: provider.dataBits,
                  dropdownColor: AppColors.surface,
                  style: AppTheme.bodyMedium,
                  underline: Container(),
                  items: [5, 6, 7, 8].map((bits) {
                    return DropdownMenuItem(value: bits, child: Text('$bits'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setDataBits(value);
                  },
                ),
              ),

              const Divider(color: AppColors.divider),

              // Parity
              _buildSettingRow(
                label: 'Parity',
                child: DropdownButton<String>(
                  value: provider.parity,
                  dropdownColor: AppColors.surface,
                  style: AppTheme.bodyMedium,
                  underline: Container(),
                  items: ['None', 'Even', 'Odd'].map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setParity(value);
                  },
                ),
              ),

              const Divider(color: AppColors.divider),

              // Stop Bits
              _buildSettingRow(
                label: 'Stop Bits',
                child: DropdownButton<int>(
                  value: provider.stopBits,
                  dropdownColor: AppColors.surface,
                  style: AppTheme.bodyMedium,
                  underline: Container(),
                  items: [1, 2].map((bits) {
                    return DropdownMenuItem(value: bits, child: Text('$bits'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setStopBits(value);
                  },
                ),
              ),

              const Divider(color: AppColors.divider),

              // Handshake
              _buildSettingRow(
                label: 'Handshake',
                child: DropdownButton<String>(
                  value: provider.handshake,
                  dropdownColor: AppColors.surface,
                  style: AppTheme.bodyMedium,
                  underline: Container(),
                  items: ['None', 'Hardware', 'Software'].map((hs) {
                    return DropdownMenuItem(value: hs, child: Text(hs));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setHandshake(value);
                  },
                ),
              ),

              const Divider(color: AppColors.divider),

              // Slave Address
              _buildSettingRow(
                label: AppStrings.slaveAddress,
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    controller: TextEditingController(
                      text: provider.slaveAddress.toString(),
                    ),
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
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
      },
    );
  }

  /// Build setting row
  Widget _buildSettingRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          child,
        ],
      ),
    );
  }

  /// Build connect button
  Widget _buildConnectButton() {
    return Consumer<ModbusProvider>(
      builder: (context, provider, _) {
        return CustomButton(
          text: AppStrings.connect,
          icon: Icons.link,
          color: AppColors.success,
          onPressed: provider.selectedPort != null
              ? () => _handleConnect(provider)
              : null,
          isLoading: provider.status == ConnectionStatus.connecting,
        ).animate().fadeIn(delay: 300.ms).scale();
      },
    );
  }

  /// Handle connect
  Future<void> _handleConnect(ModbusProvider provider) async {
    await provider.connect();
    if (provider.isConnected && mounted) {
      Navigator.pop(context);
    }
  }
}
