import 'package:flutter/material.dart';
import 'package:libserialport/libserialport.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/connection_card.dart';

/// Debug screen to check available serial ports
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<String> _ports = [];
  Map<String, Map<String, dynamic>> _portInfo = {};
  bool _isScanning = false;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _scanPorts();
  }

  Future<void> _scanPorts() async {
    setState(() {
      _isScanning = true;
      _debugInfo = '';
    });

    try {
      // Get available serial ports
      final ports = SerialPort.availablePorts;

      setState(() {
        _ports = ports;
        _debugInfo += '=== Available Serial Ports ===\n';
        _debugInfo += 'Found ${ports.length} port(s)\n\n';

        if (ports.isEmpty) {
          _debugInfo += 'No serial ports found!\n\n';
          _debugInfo += '⚠️ This might mean:\n';
          _debugInfo += '  - No USB serial devices connected\n';
          _debugInfo += '  - Permissions issue\n';
          _debugInfo += '  - Platform not supported\n\n';
        } else {
          // Get detailed info for each port
          for (var portName in ports) {
            try {
              final port = SerialPort(portName);
              final info = {
                'name': portName,
                'description': port.description ?? 'N/A',
                'manufacturer': port.manufacturer ?? 'N/A',
                'productId': port.productId != null
                    ? '0x${port.productId!.toRadixString(16).padLeft(4, '0').toUpperCase()}'
                    : 'N/A',
                'vendorId': port.vendorId != null
                    ? '0x${port.vendorId!.toRadixString(16).padLeft(4, '0').toUpperCase()}'
                    : 'N/A',
                'serialNumber': port.serialNumber ?? 'N/A',
              };
              _portInfo[portName] = info;

              _debugInfo += 'Port: $portName\n';
              _debugInfo += '  Description: ${info['description']}\n';
              _debugInfo += '  Manufacturer: ${info['manufacturer']}\n';
              _debugInfo += '  VID: ${info['vendorId']}\n';
              _debugInfo += '  PID: ${info['productId']}\n';
              _debugInfo += '  Serial: ${info['serialNumber']}\n\n';

              port.dispose();
            } catch (e) {
              _debugInfo += 'Port: $portName\n';
              _debugInfo += '  Error getting info: $e\n\n';
            }
          }
        }

        _debugInfo += '=== Common Serial Port Paths ===\n';
        _debugInfo += 'Linux/Android paths to check:\n';
        _debugInfo += '  /dev/ttyUSB0\n';
        _debugInfo += '  /dev/ttyUSB1\n';
        _debugInfo += '  /dev/ttyACM0\n';
        _debugInfo += '  /dev/ttyS0\n';
        _debugInfo += '  /dev/ttyS1\n\n';

        _debugInfo += '=== Debugging Tips ===\n';
        _debugInfo += '1. Check via ADB:\n';
        _debugInfo += '   adb shell ls -l /dev/tty*\n\n';
        _debugInfo += '2. Check permissions:\n';
        _debugInfo += '   adb shell ls -la /dev/ttyUSB*\n\n';
        _debugInfo += '3. Check kernel messages:\n';
        _debugInfo += '   adb shell dmesg | grep tty\n\n';
        _debugInfo += '4. For internal serial ports:\n';
        _debugInfo += '   May require root access or\n';
        _debugInfo += '   special permissions\n';
      });
    } catch (e) {
      setState(() {
        _debugInfo += '=== Error Scanning Ports ===\n';
        _debugInfo += 'Error: $e\n';
      });
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPortList(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildDebugInfo(),
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

  Widget _buildAppBar() {
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
          Text('Debug Serial Ports', style: AppTheme.headlineMedium),
          const Spacer(),
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            color: AppColors.primaryLight,
            onPressed: _isScanning ? null : _scanPorts,
          ),
        ],
      ),
    );
  }

  Widget _buildPortList() {
    return ConnectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detected Ports', style: AppTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacingM),
          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingL),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_ports.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  Icon(Icons.usb_off, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'No serial ports detected',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._ports.map((port) => _buildPortItem(port)),
        ],
      ),
    );
  }

  Widget _buildPortItem(String portName) {
    final info = _portInfo[portName];

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusM,
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.usb, color: AppColors.success),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  portName,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          if (info != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '${info['description']}',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (info['manufacturer'] != 'N/A') ...[
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                'Manufacturer: ${info['manufacturer']}',
                style: AppTheme.labelSmall,
              ),
            ],
            if (info['vendorId'] != 'N/A' || info['productId'] != 'N/A') ...[
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                'VID:${info['vendorId']} PID:${info['productId']}',
                style: AppTheme.labelSmall,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return ConnectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Debug Information', style: AppTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppTheme.borderRadiusS,
            ),
            child: SelectableText(
              _debugInfo,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
