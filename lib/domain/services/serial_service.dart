import 'dart:async';
import 'dart:typed_data';
import 'package:libserialport/libserialport.dart';
import '../../core/utils/logger.dart';

/// Serial communication service using libserialport for internal USB ports
class SerialService {
  SerialPort? _port;
  SerialPortReader? _reader;
  String? _portName;
  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();

  /// Stream of received data
  Stream<Uint8List> get dataStream => _dataController.stream;

  /// Check if connected
  bool get isConnected => _port != null && _port!.isOpen;

  /// Get current port name
  String? get currentPortName => _portName;

  /// Get list of available serial ports
  List<String> getAvailablePorts() {
    try {
      Logger.serial('Scanning for serial ports...');
      final ports = SerialPort.availablePorts;
      Logger.serial(
        'Found ${ports.length} serial port(s): ${ports.join(", ")}',
      );
      return ports;
    } catch (e, stackTrace) {
      Logger.error('Failed to list serial ports', 'SERIAL', e, stackTrace);
      return [];
    }
  }

  /// Get detailed port information
  Map<String, dynamic> getPortInfo(String portName) {
    try {
      final port = SerialPort(portName);
      return {
        'name': portName,
        'description': port.description ?? 'N/A',
        'manufacturer': port.manufacturer ?? 'N/A',
        'productId': port.productId?.toRadixString(16) ?? 'N/A',
        'vendorId': port.vendorId?.toRadixString(16) ?? 'N/A',
        'serialNumber': port.serialNumber ?? 'N/A',
      };
    } catch (e) {
      return {'name': portName, 'error': e.toString()};
    }
  }

  /// Connect to serial port
  Future<bool> connect({
    required String portName,
    int baudRate = 9600,
    int dataBits = 8,
    int stopBits = 1,
    int parity = 0, // 0: None, 1: Odd, 2: Even
  }) async {
    try {
      Logger.serial('Connecting to port: $portName');

      // Close existing connection
      await disconnect();

      // Create port
      _port = SerialPort(portName);

      // Open port
      if (!_port!.openReadWrite()) {
        final error = SerialPort.lastError;
        Logger.error(
          'Failed to open port: ${error?.message ?? "Unknown error"}',
          'SERIAL',
        );
        _port?.dispose();
        _port = null;
        return false;
      }

      // Configure port
      final config = SerialPortConfig();
      config.baudRate = baudRate;
      config.bits = dataBits;
      config.stopBits = stopBits;

      // Convert parity: 0=None, 1=Odd, 2=Even
      if (parity == 0) {
        config.parity = SerialPortParity.none;
      } else if (parity == 1) {
        config.parity = SerialPortParity.odd;
      } else if (parity == 2) {
        config.parity = SerialPortParity.even;
      }

      _port!.config = config;
      _portName = portName;

      // Set up reader for incoming data
      _reader = SerialPortReader(_port!);
      _reader!.stream.listen(
        (data) {
          final bytes = Uint8List.fromList(data);
          _dataController.add(bytes);
          Logger.serial('Received ${bytes.length} bytes');
        },
        onError: (error) {
          Logger.error('Serial stream error', 'SERIAL', error);
        },
      );

      Logger.serial('Successfully connected at $baudRate baud');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to connect', 'SERIAL', e, stackTrace);
      _port?.dispose();
      _port = null;
      _portName = null;
      return false;
    }
  }

  /// Disconnect from port
  Future<void> disconnect() async {
    try {
      _reader?.close();
      _reader = null;

      _port?.close();
      _port?.dispose();
      _port = null;
      _portName = null;

      Logger.serial('Disconnected');
    } catch (e, stackTrace) {
      Logger.error('Error during disconnect', 'SERIAL', e, stackTrace);
    }
  }

  /// Write data to serial port
  Future<bool> write(Uint8List data) async {
    if (_port == null || !_port!.isOpen) {
      Logger.warning('Cannot write: not connected', 'SERIAL');
      return false;
    }

    try {
      final written = _port!.write(data);
      Logger.serial(
        'Sent $written/${data.length} bytes: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
      return written == data.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to write data', 'SERIAL', e, stackTrace);
      return false;
    }
  }

  /// Read data from serial port with timeout
  Future<Uint8List?> read({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (_port == null || !_port!.isOpen) {
      Logger.warning('Cannot read: not connected', 'SERIAL');
      return null;
    }

    try {
      final data = await dataStream.first.timeout(timeout);
      return data;
    } on TimeoutException {
      Logger.warning('Read timeout', 'SERIAL');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to read data', 'SERIAL', e, stackTrace);
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _dataController.close();
  }
}
