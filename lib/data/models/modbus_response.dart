import 'dart:typed_data';

/// Modbus RTU response model
class ModbusResponse {
  final int slaveAddress;
  final int functionCode;
  final List<int> data;
  final bool isValid;
  final String? errorMessage;

  ModbusResponse({
    required this.slaveAddress,
    required this.functionCode,
    required this.data,
    required this.isValid,
    this.errorMessage,
  });

  /// Parse Modbus RTU response from bytes
  factory ModbusResponse.fromBytes(Uint8List bytes) {
    if (bytes.length < 5) {
      return ModbusResponse(
        slaveAddress: 0,
        functionCode: 0,
        data: [],
        isValid: false,
        errorMessage: 'Response too short',
      );
    }

    final slaveAddress = bytes[0];
    final functionCode = bytes[1];

    // Check for exception response
    if (functionCode >= 0x80) {
      final exceptionCode = bytes[2];
      return ModbusResponse(
        slaveAddress: slaveAddress,
        functionCode: functionCode & 0x7F,
        data: [],
        isValid: false,
        errorMessage: _getExceptionMessage(exceptionCode),
      );
    }

    // Extract data without CRC
    final dataLength = bytes.length - 2; // Remove CRC bytes
    final frameData = bytes.sublist(0, dataLength);

    // Verify CRC
    final receivedCRC = bytes[dataLength] | (bytes[dataLength + 1] << 8);
    final calculatedCRC = _calculateCRC(frameData);

    if (receivedCRC != calculatedCRC) {
      return ModbusResponse(
        slaveAddress: slaveAddress,
        functionCode: functionCode,
        data: [],
        isValid: false,
        errorMessage: 'CRC verification failed',
      );
    }

    // Extract register values
    final byteCount = bytes[2];
    final values = <int>[];

    for (var i = 0; i < byteCount; i += 2) {
      if (i + 4 < bytes.length) {
        final highByte = bytes[3 + i];
        final lowByte = bytes[4 + i];
        values.add((highByte << 8) | lowByte);
      }
    }

    return ModbusResponse(
      slaveAddress: slaveAddress,
      functionCode: functionCode,
      data: values,
      isValid: true,
    );
  }

  /// Calculate CRC16 for Modbus RTU
  static int _calculateCRC(Uint8List data) {
    int crc = 0xFFFF;

    for (var byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc >>= 1;
          crc ^= 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }

    return crc;
  }

  /// Get exception message from code
  static String _getExceptionMessage(int code) {
    switch (code) {
      case 0x01:
        return 'Illegal Function';
      case 0x02:
        return 'Illegal Data Address';
      case 0x03:
        return 'Illegal Data Value';
      case 0x04:
        return 'Slave Device Failure';
      case 0x05:
        return 'Acknowledge';
      case 0x06:
        return 'Slave Device Busy';
      case 0x08:
        return 'Memory Parity Error';
      case 0x0A:
        return 'Gateway Path Unavailable';
      case 0x0B:
        return 'Gateway Target Device Failed to Respond';
      default:
        return 'Unknown Exception 0x${code.toRadixString(16)}';
    }
  }

  /// Convert register values to ASCII string
  String toAsciiString() {
    if (!isValid || data.isEmpty) return '';

    final buffer = StringBuffer();
    for (var value in data) {
      // Each register contains 2 ASCII characters
      final highByte = (value >> 8) & 0xFF;
      final lowByte = value & 0xFF;

      if (highByte != 0) buffer.write(String.fromCharCode(highByte));
      if (lowByte != 0) buffer.write(String.fromCharCode(lowByte));
    }

    return buffer.toString().trim();
  }

  @override
  String toString() {
    if (!isValid) {
      return 'ModbusResponse(ERROR: $errorMessage)';
    }
    return 'ModbusResponse(slave: $slaveAddress, func: 0x${functionCode.toRadixString(16)}, '
        'data: $data)';
  }
}
