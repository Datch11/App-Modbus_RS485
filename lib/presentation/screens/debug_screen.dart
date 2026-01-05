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
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanPorts();
  }

  Future<void> _scanPorts() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Get available serial ports
      final ports = SerialPort.availablePorts;

      setState(() {
        _ports = ports;
      });
    } catch (e) {
      setState(() {
        _ports = [];
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
                    children: [_buildPortList()],
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusM,
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Row(
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
    );
  }
}
