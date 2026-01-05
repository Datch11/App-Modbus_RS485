import 'dart:async';
import 'dart:typed_data';
import '../../core/utils/logger.dart';
import 'native_serial_service.dart';

/// Serial communication service for Android
/// Uses NativeSerialService via Platform Channel
class SerialService {
  NativeSerialService? _nativeService;
  String? _portName;
  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();

  /// Initialize service
  SerialService() {
    _nativeService = NativeSerialService();
    // Forward native stream to common stream
    _nativeService!.dataStream.listen((data) {
      _dataController.add(data);
    });
  }

  /// Stream of received data
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// Check if connected
  bool get isConnected => _portName != null;

  /// Get current port name
  String? get currentPortName => _portName;

  /// Get available ports (async)
  Future<List<String>> getAvailablePortsAsync() async {
    try {
      Logger.serial('Scanning for serial ports...');
      final ports = await _nativeService!.getAvailablePorts();
      Logger.serial(
        'Found ${ports.length} serial port(s): ${ports.join(", ")}',
      );
      return ports;
    } catch (e, stackTrace) {
      Logger.error('Failed to list serial ports', 'SERIAL', e, stackTrace);
      return [];
    }
  }

  /// Connect to serial port
  Future<bool> connect({
    required String portName,
    required int baudRate,
    int dataBits = 8,
    int stopBits = 1,
    int parity = 0, // 0=None, 1=Odd, 2=Even
  }) async {
    try {
      Logger.serial('Connecting to $portName at $baudRate baud...');

      final success = await _nativeService!.connect(
        portName: portName,
        baudRate: baudRate,
        dataBits: dataBits,
        stopBits: stopBits,
        parity: parity,
      );

      if (success) {
        _portName = portName;
        Logger.serial('Successfully connected');
        return true;
      } else {
        Logger.warning('Failed to connect', 'SERIAL');
        return false;
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to connect', 'SERIAL', e, stackTrace);
      _portName = null;
      return false;
    }
  }

  /// Write data to serial port
  Future<bool> write(Uint8List data) async {
    try {
      return await _nativeService!.write(data);
    } catch (e, stackTrace) {
      Logger.error('Write failed', 'SERIAL', e, stackTrace);
      return false;
    }
  }

  /// Disconnect from serial port
  Future<void> disconnect() async {
    try {
      Logger.serial('Disconnecting...');
      await _nativeService!.disconnect();
      _portName = null;
      Logger.serial('Disconnected');
    } catch (e, stackTrace) {
      Logger.error('Disconnect failed', 'SERIAL', e, stackTrace);
    }
  }

  /// Dispose resources
  void dispose() {
    _nativeService?.dispose();
    _dataController.close();
  }
}
