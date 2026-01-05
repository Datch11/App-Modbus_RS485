import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../domain/services/serial_service.dart';
import '../domain/services/modbus_service.dart';
import '../data/models/message_history.dart';
import '../core/utils/logger.dart';
import '../core/constants/data_display_mode.dart';

/// Connection status enum
enum ConnectionStatus { disconnected, connecting, connected, error }

/// Main provider for Modbus communication
class ModbusProvider with ChangeNotifier {
  final SerialService _serialService = SerialService();
  late final ModbusService _modbusService;

  // State
  ConnectionStatus _status = ConnectionStatus.disconnected;
  List<String> _availablePorts = [];
  String? _selectedPort;
  int _baudRate = 9600;
  int _slaveAddress = 1;
  // Separate port settings
  int _dataBits = 8;
  String _parity = 'None'; // None, Even, Odd
  int _stopBits = 1;
  String _handshake = 'None'; // None, Hardware, Software
  final Queue<MessageHistory> _messageHistory = Queue();
  bool _isLoading = false;
  String? _errorMessage;
  DataDisplayMode _displayMode = DataDisplayMode.ascii;

  ModbusProvider() {
    _modbusService = ModbusService(_serialService);
    Logger.info('ModbusProvider initialized', 'PROVIDER');
  }

  // Getters
  ConnectionStatus get status => _status;
  List<String> get availablePorts => _availablePorts;
  String? get selectedPort => _selectedPort;
  int get baudRate => _baudRate;
  int get slaveAddress => _slaveAddress;
  int get dataBits => _dataBits;
  String get parity => _parity;
  int get stopBits => _stopBits;
  String get handshake => _handshake;
  List<MessageHistory> get messageHistory => _messageHistory.toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == ConnectionStatus.connected;
  DataDisplayMode get displayMode => _displayMode;

  /// Scan for available serial ports
  Future<void> scanPorts() async {
    try {
      _setLoading(true);
      Logger.ui('Scanning for serial ports...');
      _availablePorts = await _serialService.getAvailablePortsAsync();
      notifyListeners();
      Logger.ui('Found ${_availablePorts.length} port(s)');
    } catch (e, stackTrace) {
      Logger.error('Failed to scan ports', 'PROVIDER', e, stackTrace);
      _setError('Failed to scan ports: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select port
  void selectPort(String port) {
    _selectedPort = port;
    Logger.ui('Selected port: $port');
    notifyListeners();
  }

  /// Set baud rate
  void setBaudRate(int rate) {
    _baudRate = rate;
    Logger.ui('Baud rate set to $rate');
    notifyListeners();
  }

  /// Set slave address
  void setSlaveAddress(int address) {
    _slaveAddress = address;
    _modbusService.setSlaveAddress(address);
    Logger.ui('Slave address set to $address');
    notifyListeners();
  }

  /// Set data bits
  void setDataBits(int bits) {
    _dataBits = bits;
    Logger.ui('Data bits set to $bits');
    notifyListeners();
  }

  /// Set parity
  void setParity(String parity) {
    _parity = parity;
    Logger.ui('Parity set to $parity');
    notifyListeners();
  }

  /// Set stop bits
  void setStopBits(int bits) {
    _stopBits = bits;
    Logger.ui('Stop bits set to $bits');
    notifyListeners();
  }

  /// Set handshake
  void setHandshake(String handshake) {
    _handshake = handshake;
    Logger.ui('Handshake set to $handshake');
    notifyListeners();
  }

  /// Connect to selected port
  Future<void> connect() async {
    if (_selectedPort == null) {
      _setError('Please select a port first');
      return;
    }

    try {
      _setStatus(ConnectionStatus.connecting);
      _errorMessage = null;

      // Convert parity string to int
      final parityValue = _parseParity(_parity);

      Logger.ui('Connecting to port $_selectedPort...');
      final success = await _serialService.connect(
        portName: _selectedPort!,
        baudRate: _baudRate,
        dataBits: _dataBits,
        stopBits: _stopBits,
        parity: parityValue,
      );

      if (success) {
        _setStatus(ConnectionStatus.connected);
        _addHistory(
          MessageHistory(
            message: 'Connected successfully to $_selectedPort',
            timestamp: DateTime.now(),
            isSent: false,
            isSuccess: true,
          ),
        );
      } else {
        _setStatus(ConnectionStatus.error);
        _setError('Failed to connect to port');
      }
    } catch (e, stackTrace) {
      Logger.error('Connection error', 'PROVIDER', e, stackTrace);
      _setStatus(ConnectionStatus.error);
      _setError('Connection error: $e');
    }
  }

  /// Disconnect from port
  Future<void> disconnect() async {
    try {
      Logger.ui('Disconnecting...');
      await _serialService.disconnect();
      _setStatus(ConnectionStatus.disconnected);
      _selectedPort = null;

      _addHistory(
        MessageHistory(
          message: 'Disconnected',
          timestamp: DateTime.now(),
          isSent: false,
          isSuccess: true,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('Disconnect error', 'PROVIDER', e, stackTrace);
    }
  }

  /// Send text message via Modbus
  Future<void> sendMessage(String message) async {
    if (!isConnected) {
      _setError('Not connected to device');
      return;
    }

    if (message.trim().isEmpty) {
      _setError('Message cannot be empty');
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      Logger.ui('Sending message: "$message"');
      final success = await _modbusService.sendTextMessage(message);

      _addHistory(
        MessageHistory(
          message: message,
          rawBytes: message.codeUnits,
          timestamp: DateTime.now(),
          isSent: true,
          isSuccess: success,
          errorMessage: success ? null : 'Failed to send',
        ),
      );

      if (!success) {
        _setError('Failed to send message');
      }
    } catch (e, stackTrace) {
      Logger.error('Send message error', 'PROVIDER', e, stackTrace);
      _setError('Error sending message: $e');

      _addHistory(
        MessageHistory(
          message: message,
          rawBytes: message.codeUnits,
          timestamp: DateTime.now(),
          isSent: true,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Send message from bytes (for hex input)
  Future<void> sendMessageWithBytes({
    required List<int> bytes,
    required String displayText,
    String lineEnding = 'None',
  }) async {
    if (!isConnected) {
      _setError('Not connected to device');
      return;
    }

    if (bytes.isEmpty) {
      _setError('Message cannot be empty');
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      // Apply line ending
      final finalBytes = _applyLineEnding(bytes, lineEnding);

      Logger.ui('Sending ${finalBytes.length} bytes: $displayText');

      // Send raw bytes via serial
      final success = await _serialService.write(
        Uint8List.fromList(finalBytes),
      );

      _addHistory(
        MessageHistory(
          message: displayText,
          rawBytes: finalBytes,
          timestamp: DateTime.now(),
          isSent: true,
          isSuccess: success,
          errorMessage: success ? null : 'Failed to send',
        ),
      );

      if (!success) {
        _setError('Failed to send message');
      }
    } catch (e, stackTrace) {
      Logger.error('Send bytes error', 'PROVIDER', e, stackTrace);
      _setError('Error sending bytes: $e');

      _addHistory(
        MessageHistory(
          message: displayText,
          rawBytes: bytes,
          timestamp: DateTime.now(),
          isSent: true,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Clear message history
  void clearHistory() {
    _messageHistory.clear();
    notifyListeners();
    Logger.ui('Message history cleared');
  }

  /// Set display mode (ASCII or HEX)
  void setDisplayMode(DataDisplayMode mode) {
    if (_displayMode != mode) {
      _displayMode = mode;
      Logger.ui('Display mode changed to ${mode.label}');
      notifyListeners();
    }
  }

  /// Toggle display mode
  void toggleDisplayMode() {
    _displayMode = _displayMode == DataDisplayMode.ascii
        ? DataDisplayMode.hex
        : DataDisplayMode.ascii;
    notifyListeners();
  }

  // Private helpers

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setStatus(ConnectionStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    Logger.warning(message, 'PROVIDER');
    notifyListeners();
  }

  void _addHistory(MessageHistory message) {
    _messageHistory.addLast(message);

    // Limit history to last 100 messages to prevent memory growth
    // Using Queue.removeFirst() is O(1) vs List.removeRange() O(n)
    while (_messageHistory.length > 100) {
      _messageHistory.removeFirst();
    }

    notifyListeners();
  }

  int _parseParity(String parity) {
    switch (parity.toLowerCase()) {
      case 'odd':
        return 1;
      case 'even':
        return 2;
      default:
        return 0; // None
    }
  }

  List<int> _applyLineEnding(List<int> bytes, String lineEnding) {
    final result = List<int>.from(bytes);
    switch (lineEnding) {
      case 'LF':
        result.add(0x0A);
        break;
      case 'CR':
        result.add(0x0D);
        break;
      case 'CR+LF':
        result.addAll([0x0D, 0x0A]);
        break;
      default:
        // No line ending
        break;
    }
    return result;
  }

  @override
  void dispose() {
    _serialService.dispose();
    super.dispose();
  }
}
