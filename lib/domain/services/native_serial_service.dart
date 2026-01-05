import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';

/// Native serial service using Platform Channel to access /dev/ttyS* ports on Android
class NativeSerialService {
  static const platform = MethodChannel('com.example.app/native_serial');

  /// Stream controller for incoming data
  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();

  /// Stream of received data
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// Currently connected port path
  String? _currentPort;

  /// Timer for polling read data
  Timer? _readTimer;

  /// Get list of available serial ports
  Future<List<String>> getAvailablePorts() async {
    try {
      final List<dynamic> result = await platform.invokeMethod(
        'getAvailablePorts',
      );
      return result.cast<String>();
    } catch (e, stackTrace) {
      Logger.error('Failed to get ports', 'NATIVE_SERIAL', e, stackTrace);
      return [];
    }
  }

  /// Open serial port with configuration
  Future<bool> connect({
    required String portName,
    required int baudRate,
    int dataBits = 8,
    int stopBits = 1,
    int parity = 0, // 0=None, 1=Odd, 2=Even
  }) async {
    try {
      Logger.serial('Opening port: $portName at $baudRate baud');

      final result = await platform.invokeMethod('openPort', {
        'path': portName,
        'baudRate': baudRate,
        'dataBits': dataBits,
        'stopBits': stopBits,
        'parity': parity,
      });

      if (result as bool) {
        _currentPort = portName;
        _startReading();
        Logger.serial('Successfully opened $portName');
        return true;
      } else {
        Logger.warning('Failed to open port', 'NATIVE_SERIAL');
        return false;
      }
    } catch (e, stackTrace) {
      Logger.error('Open port error', 'NATIVE_SERIAL', e, stackTrace);
      return false;
    }
  }

  /// Write data to serial port
  Future<bool> write(Uint8List data) async {
    try {
      final result = await platform.invokeMethod('write', {'data': data});

      if (result as bool) {
        Logger.serial('Sent ${data.length} bytes');
        return true;
      } else {
        Logger.warning('Write failed', 'NATIVE_SERIAL');
        return false;
      }
    } catch (e, stackTrace) {
      Logger.error('Write error', 'NATIVE_SERIAL', e, stackTrace);
      return false;
    }
  }

  /// Read data from serial port (single read)
  Future<Uint8List> read({int timeout = 1000}) async {
    try {
      final result = await platform.invokeMethod('read', {'timeout': timeout});

      if (result is List<dynamic>) {
        return Uint8List.fromList(result.cast<int>());
      } else if (result is Uint8List) {
        return result;
      } else {
        return Uint8List(0);
      }
    } catch (e, stackTrace) {
      Logger.error('Read error', 'NATIVE_SERIAL', e, stackTrace);
      return Uint8List(0);
    }
  }

  /// Close serial port
  Future<void> disconnect() async {
    try {
      _stopReading();
      await platform.invokeMethod('closePort');
      _currentPort = null;
      Logger.serial('Port closed');
    } catch (e, stackTrace) {
      Logger.error('Close error', 'NATIVE_SERIAL', e, stackTrace);
    }
  }

  /// Check if port is open
  Future<bool> isOpen() async {
    try {
      final result = await platform.invokeMethod('isOpen');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  /// Get current port name
  String? getCurrentPort() {
    return _currentPort;
  }

  /// Start polling for incoming data
  void _startReading() {
    _stopReading();

    _readTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) async {
      try {
        final data = await read(timeout: 100);
        if (data.isNotEmpty) {
          _dataController.add(data);
          Logger.serial('Received ${data.length} bytes');
        }
      } catch (e) {
        // Ignore read errors during polling
      }
    });
  }

  /// Stop reading timer
  void _stopReading() {
    _readTimer?.cancel();
    _readTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _stopReading();
    _dataController.close();
  }
}
