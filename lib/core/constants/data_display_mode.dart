/// Display mode for received data
enum DataDisplayMode { ascii, hex }

extension DataDisplayModeExtension on DataDisplayMode {
  String get label {
    switch (this) {
      case DataDisplayMode.ascii:
        return 'ASCII';
      case DataDisplayMode.hex:
        return 'HEX';
    }
  }
}
