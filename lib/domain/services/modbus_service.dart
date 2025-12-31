import 'dart:async';
import 'dart:convert';
import '../services/serial_service.dart';
import '../../data/models/modbus_request.dart';
import '../../data/models/modbus_response.dart';
import '../../core/utils/logger.dart';

/// Modbus RTU protocol service
class ModbusService {
  final SerialService _serialService;

  int _slaveAddress = 1;
  Duration _timeout = const Duration(seconds: 2);
  int _retryAttempts = 3;

  ModbusService(this._serialService);

  /// Set slave address
  void setSlaveAddress(int address) {
    if (address >= 1 && address <= 247) {
      _slaveAddress = address;
      Logger.info('Slave address set to $address', 'MODBUS');
    }
  }

  /// Set timeout duration
  void setTimeout(Duration timeout) {
    _timeout = timeout;
  }

  /// Set retry attempts
  void setRetryAttempts(int attempts) {
    _retryAttempts = attempts;
  }

  /// Send text message via Modbus
  Future<bool> sendTextMessage(String text) async {
    try {
      Logger.modbus('Sending text: "$text"', isSent: true);

      // Convert text to registers
      final registers = _textToRegisters(text);

      // Create write multiple registers request
      final request = ModbusRequest.writeMultipleRegisters(
        slaveAddress: _slaveAddress,
        startAddress: 0,
        values: registers,
      );

      // Send request with retry
      for (var attempt = 1; attempt <= _retryAttempts; attempt++) {
        Logger.debug('Attempt $attempt of $_retryAttempts', 'MODBUS');

        final response = await _sendRequest(request);

        if (response != null && response.isValid) {
          Logger.modbus('Text sent successfully', isSent: true);
          return true;
        }

        if (attempt < _retryAttempts) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      Logger.error(
        'Failed to send text after $_retryAttempts attempts',
        'MODBUS',
      );
      return false;
    } catch (e, stackTrace) {
      Logger.error('Error sending text', 'MODBUS', e, stackTrace);
      return false;
    }
  }

  /// Read text message from Modbus
  Future<String?> readTextMessage({int registerCount = 10}) async {
    try {
      Logger.modbus('Reading text message', isSent: true);

      final request = ModbusRequest.readHoldingRegisters(
        slaveAddress: _slaveAddress,
        startAddress: 0,
        quantity: registerCount,
      );

      final response = await _sendRequest(request);

      if (response != null && response.isValid) {
        final text = response.toAsciiString();
        Logger.modbus('Received text: "$text"', isSent: false);
        return text;
      }

      return null;
    } catch (e, stackTrace) {
      Logger.error('Error reading text', 'MODBUS', e, stackTrace);
      return null;
    }
  }

  /// Send Modbus request and wait for response
  Future<ModbusResponse?> _sendRequest(ModbusRequest request) async {
    try {
      // Convert request to bytes
      final requestBytes = request.toBytes();

      // Send request
      final sent = await _serialService.write(requestBytes);
      if (!sent) {
        Logger.error('Failed to send request', 'MODBUS');
        return null;
      }

      // Wait for response
      final responseBytes = await _serialService.read(timeout: _timeout);
      if (responseBytes == null) {
        Logger.warning('No response received', 'MODBUS');
        return null;
      }

      // Parse response
      final response = ModbusResponse.fromBytes(responseBytes);

      if (!response.isValid) {
        Logger.error('Invalid response: ${response.errorMessage}', 'MODBUS');
      }

      return response;
    } catch (e, stackTrace) {
      Logger.error('Error in request/response', 'MODBUS', e, stackTrace);
      return null;
    }
  }

  /// Convert text to Modbus registers (16-bit values)
  List<int> _textToRegisters(String text) {
    final registers = <int>[];
    final bytes = utf8.encode(text);

    // Pack bytes into 16-bit registers (2 bytes per register)
    for (var i = 0; i < bytes.length; i += 2) {
      final highByte = bytes[i];
      final lowByte = (i + 1 < bytes.length) ? bytes[i + 1] : 0;
      final register = (highByte << 8) | lowByte;
      registers.add(register);
    }

    // Ensure at least one register
    if (registers.isEmpty) {
      registers.add(0);
    }

    Logger.debug(
      'Converted "$text" to ${registers.length} registers',
      'MODBUS',
    );
    return registers;
  }

  /// Write single register
  Future<bool> writeSingleRegister(int address, int value) async {
    try {
      final request = ModbusRequest.writeSingleRegister(
        slaveAddress: _slaveAddress,
        address: address,
        value: value,
      );

      final response = await _sendRequest(request);
      return response != null && response.isValid;
    } catch (e, stackTrace) {
      Logger.error('Error writing register', 'MODBUS', e, stackTrace);
      return false;
    }
  }

  /// Read holding registers
  Future<List<int>?> readHoldingRegisters(
    int startAddress,
    int quantity,
  ) async {
    try {
      final request = ModbusRequest.readHoldingRegisters(
        slaveAddress: _slaveAddress,
        startAddress: startAddress,
        quantity: quantity,
      );

      final response = await _sendRequest(request);

      if (response != null && response.isValid) {
        return response.data;
      }

      return null;
    } catch (e, stackTrace) {
      Logger.error('Error reading registers', 'MODBUS', e, stackTrace);
      return null;
    }
  }
}
