/// Utilities for hex/binary data conversion
class HexUtils {
  HexUtils._();

  /// Convert bytes to hex string (e.g., [0x48, 0x65] → "48 65")
  static String bytesToHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Convert hex string to bytes (e.g., "48 65" → [0x48, 0x65])
  /// Spaces are optional and will be ignored
  static List<int> hexToBytes(String hex) {
    // Remove all whitespace
    final cleanHex = hex.replaceAll(RegExp(r'\s+'), '');

    // Validate hex string
    if (!RegExp(r'^[0-9A-Fa-f]*$').hasMatch(cleanHex)) {
      throw FormatException('Invalid hex string: $hex');
    }

    if (cleanHex.length.isOdd) {
      throw FormatException('Hex string must have even length: $hex');
    }

    final bytes = <int>[];
    for (var i = 0; i < cleanHex.length; i += 2) {
      final byteStr = cleanHex.substring(i, i + 2);
      bytes.add(int.parse(byteStr, radix: 16));
    }

    return bytes;
  }

  /// Check if a string is valid hex
  static bool isValidHex(String hex) {
    final cleanHex = hex.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^[0-9A-Fa-f]*$').hasMatch(cleanHex) &&
        cleanHex.length.isEven;
  }

  /// Convert bytes to ASCII string, replacing non-printable chars with '.'
  static String bytesToAscii(List<int> bytes, {String placeholder = '·'}) {
    return bytes.map((b) {
      // Printable ASCII range: 32-126
      if (b >= 32 && b <= 126) {
        return String.fromCharCode(b);
      }
      return placeholder;
    }).join();
  }

  /// Format bytes with both hex and ASCII (e.g., "48 65 6C 6C 6F | Hello")
  static String formatBytesWithAscii(List<int> bytes) {
    final hex = bytesToHex(bytes);
    final ascii = bytesToAscii(bytes);
    return '$hex | $ascii';
  }
}
