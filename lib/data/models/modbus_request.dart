import 'dart:typed_data';

/// Modbus RTU request model
class ModbusRequest {
  final int slaveAddress;
  final int functionCode;
  final int startAddress;
  final int quantity;
  final List<int>? values;

  ModbusRequest({
    required this.slaveAddress,
    required this.functionCode,
    required this.startAddress,
    required this.quantity,
    this.values,
  });

  /// Build Modbus RTU frame with CRC
  Uint8List toBytes() {
    final buffer = <int>[];

    // Add slave address
    buffer.add(slaveAddress);

    // Add function code
    buffer.add(functionCode);

    // Add start address (2 bytes, big-endian)
    buffer.add((startAddress >> 8) & 0xFF);
    buffer.add(startAddress & 0xFF);

    if (functionCode == 0x03 || functionCode == 0x04) {
      // Read Holding/Input Registers
      buffer.add((quantity >> 8) & 0xFF);
      buffer.add(quantity & 0xFF);
    } else if (functionCode == 0x06) {
      // Write Single Register
      if (values != null && values!.isNotEmpty) {
        buffer.add((values![0] >> 8) & 0xFF);
        buffer.add(values![0] & 0xFF);
      }
    } else if (functionCode == 0x10) {
      // Write Multiple Registers
      buffer.add((quantity >> 8) & 0xFF);
      buffer.add(quantity & 0xFF);

      final byteCount = quantity * 2;
      buffer.add(byteCount);

      if (values != null) {
        for (var value in values!) {
          buffer.add((value >> 8) & 0xFF);
          buffer.add(value & 0xFF);
        }
      }
    }

    // Calculate and add CRC
    final crc = _calculateCRC(buffer);
    buffer.add(crc & 0xFF); // CRC Low
    buffer.add((crc >> 8) & 0xFF); // CRC High

    return Uint8List.fromList(buffer);
  }

  /// Calculate CRC16 for Modbus RTU
  int _calculateCRC(List<int> data) {
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

  /// Create a read holding registers request
  factory ModbusRequest.readHoldingRegisters({
    required int slaveAddress,
    required int startAddress,
    required int quantity,
  }) {
    return ModbusRequest(
      slaveAddress: slaveAddress,
      functionCode: 0x03,
      startAddress: startAddress,
      quantity: quantity,
    );
  }

  /// Create a write single register request
  factory ModbusRequest.writeSingleRegister({
    required int slaveAddress,
    required int address,
    required int value,
  }) {
    return ModbusRequest(
      slaveAddress: slaveAddress,
      functionCode: 0x06,
      startAddress: address,
      quantity: 1,
      values: [value],
    );
  }

  /// Create a write multiple registers request
  factory ModbusRequest.writeMultipleRegisters({
    required int slaveAddress,
    required int startAddress,
    required List<int> values,
  }) {
    return ModbusRequest(
      slaveAddress: slaveAddress,
      functionCode: 0x10,
      startAddress: startAddress,
      quantity: values.length,
      values: values,
    );
  }

  @override
  String toString() {
    return 'ModbusRequest(slave: $slaveAddress, func: 0x${functionCode.toRadixString(16)}, '
        'addr: $startAddress, qty: $quantity)';
  }
}
