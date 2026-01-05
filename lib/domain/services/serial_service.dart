import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:libserialport/libserialport.dart';
import '../../core/utils/logger.dart';
import 'native_serial_service.dart';

/// Hybrid serial communication service
/// Uses NativeSerialService on Android, libserialport on other platforms
class SerialService {
  // Platform-specific backends
  SerialPort? _libPort;
  SerialPortReader? _libReader;
  NativeSerialService? _nativeService;

  String? _portName;
  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();

  /// Initialize based on platform
  SerialService() {
    if (Platform.isAndroid) {
      _nativeService = NativeSerialService();
      // Forward native stream to common stream
      _nativeService!.dataStream.listen((data) {
        _dataController.add(data);
      });
    }
  }

  /// Stream of received data
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// Check if connected
  bool get isConnected {
    if (Platform.isAndroid) {
      // We'll need to check async, so return cached state
      return _portName != null;
    } else {
      return _libPort != null && _libPort!.isOpen;
    }
  }

  /// Get current port name
  String? get currentPortName => _portName;

  /// Get list of available serial ports
  List<String> getAvailablePorts() {
    try {
      Logger.serial('Scanning for serial ports...');

      if (Platform.isAndroid) {
        // On Android, we need async call but this is sync method
        // Return empty for now, will fix with async version
        return [];
      } else {
        final ports = SerialPort.availablePorts;
        Logger.serial(
          'Found ${ports.length} serial port(s): ${ports.join(", ")}',
        );
        return ports;
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to list serial ports', 'SERIAL', e, stackTrace);
      return [];
    }
  }

  /// Get available ports (async version for Android)
  Future<List<String>> getAvailablePortsAsync() async {
    try {
      Logger.serial('Scanning for serial ports...');

      if (Platform.isAndroid) {
        final ports = await _nativeService!.getAvailablePorts();
        Logger.serial(
          'Found ${ports.length} serial port(s): ${ports.join(", ")}',
        );
        return ports;
      } else {
        final ports = SerialPort.availablePorts;
        Logger.serial(
          'Found ${ports.length} serial port(s): ${ports.join(", ")}',
        );
        return ports;
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to list serial ports', 'SERIAL', e, stackTrace);
      return [];
    }
  }

  /// Get detailed port information
  Map<String, dynamic>? getPortInfo(String portName) {
    if (Platform.isAndroid) {
      // Native ports don't have detailed info
      return {'name': portName, 'description': 'Internal UART'};
    }

    try {
      final port = SerialPort(portName);
      return {
        'name': portName,
        'description': port.description ?? 'N/A',
        'manufacturer': port.manufacturer ?? 'N/A',
        'vendorId': port.vendorId,
        'productId': port.productId,
        'serialNumber': port.serialNumber ?? 'N/A',
      };
    } catch (e) {
      return null;
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

      if (Platform.isAndroid) {
        // Use native service
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
      } else {
        // Use libserialport
        _libPort = SerialPort(portName);

        if (!_libPort!.openReadWrite()) {
          Logger.error(
            'Failed to open port',
            'SERIAL',
            SerialPort.lastError?.message ?? 'Unknown error',
          );
          _libPort = null;
          return false;
        }

        // Configure port
        final config = _libPort!.config;
        config.baudRate = baudRate;
        config.bits = dataBits;
        config.stopBits = stopBits;
        config.parity = parity;
        _libPort!.config = config;
        _portName = portName;

        // Set up reader
        _libReader = SerialPortReader(_libPort!);
        _libReader!.stream.listen(
          (data) {
            final bytes = Uint8List.fromList(data);
            _dataController.add(bytes);
            if (kDebugMode) {
              Logger.serial('Received ${bytes.length} bytes');
            }
          },
          onError: (error) {
            Logger.error('Serial stream error', 'SERIAL', error);
          },
        );

        Logger.serial('Successfully connected at $baudRate baud');
        return true;
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to connect', 'SERIAL', e, stackTrace);
      _libPort?.close();
      _libPort = null;
      _portName = null;
      return false;
    }
  }

  /// Write data to serial port
  Future<bool> write(Uint8List data) async {
    try {
      if (Platform.isAndroid) {
        return await _nativeService!.write(data);
      } else {
        if (_libPort == null || !_libPort!.isOpen) {
          Logger.warning('Port not open', 'SERIAL');
          return false;
        }

        final written = _libPort!.write(data);
        if (kDebugMode) {
          Logger.serial('Wrote $written bytes');
        }
        return written == data.length;
      }
    } catch (e, stackTrace) {
      Logger.error('Write failed', 'SERIAL', e, stackTrace);
      return false;
    }
  }

  /// Disconnect from serial port
  Future<void> disconnect() async {
    try {
      Logger.serial('Disconnecting...');

      if (Platform.isAndroid) {
        await _nativeService!.disconnect();
      } else {
        _libReader?.close();
        _libPort?.close();
        _libReader = null;
        _libPort = null;
      }

      _portName = null;
      Logger.serial('Disconnected');
    } catch (e, stackTrace) {
      Logger.error('Disconnect failed', 'SERIAL', e, stackTrace);
    }
  }

  /// Dispose resources
  void dispose() {
    if (Platform.isAndroid) {
      _nativeService?.dispose();
    } else {
      _libReader?.close();
      _libPort?.close();
    }
    _dataController.close();
  }
}
