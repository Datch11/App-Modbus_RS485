/// Application-wide string constants
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Modbus RS485';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Serial Communication Tool';

  // Home Screen
  static const String homeTitle = 'Modbus Communication';
  static const String connectionStatus = 'Connection Status';
  static const String sendMessage = 'Send Message';
  static const String messageHistory = 'Message History';
  static const String enterMessage = 'Enter your message...';
  static const String messageHint = 'Type "hello world" to send';

  // Connection Screen
  static const String connectionTitle = 'Connection Setup';
  static const String selectDevice = 'Select USB Device';
  static const String baudRate = 'Baud Rate';
  static const String dataFormat = 'Data Format';
  static const String slaveAddress = 'Slave Address';
  static const String connect = 'Connect';
  static const String disconnect = 'Disconnect';
  static const String refresh = 'Refresh Devices';
  static const String noDevicesFound = 'No USB devices found';
  static const String scanningDevices = 'Scanning devices...';

  // Settings Screen
  static const String settingsTitle = 'Settings';
  static const String modbusSettings = 'Modbus Settings';
  static const String timeout = 'Timeout (ms)';
  static const String retryAttempts = 'Retry Attempts';
  static const String logging = 'Logging';
  static const String loggingLevel = 'Logging Level';
  static const String theme = 'Theme';
  static const String about = 'About';

  // Status Messages
  static const String statusConnected = 'Connected';
  static const String statusDisconnected = 'Disconnected';
  static const String statusConnecting = 'Connecting...';
  static const String statusError = 'Error';
  static const String statusReady = 'Ready';

  // Error Messages
  static const String errorNoDevice = 'Please select a USB device';
  static const String errorConnection = 'Connection failed';
  static const String errorTimeout = 'Connection timeout';
  static const String errorCommunication = 'Communication error';
  static const String errorPermission = 'USB permission denied';
  static const String errorInvalidData = 'Invalid data format';
  static const String errorCRC = 'CRC verification failed';
  static const String errorEmptyMessage = 'Message cannot be empty';

  // Success Messages
  static const String successConnected = 'Successfully connected';
  static const String successDisconnected = 'Disconnected';
  static const String successSent = 'Message sent successfully';

  // Buttons
  static const String btnSend = 'Send';
  static const String btnClear = 'Clear';
  static const String btnSave = 'Save';
  static const String btnCancel = 'Cancel';
  static const String btnRetry = 'Retry';
  static const String btnExport = 'Export';
  static const String btnScan = 'Scan Devices';

  // Display Mode
  static const String displayModeAscii = 'ASCII';
  static const String displayModeHex = 'HEX';

  // Line Ending Options
  static const List<String> lineEndingOptions = ['None', 'CR', 'LF', 'CR+LF'];

  // Data Bits Options
  static const List<String> dataBitsOptions = ['7', '8'];

  // Parity Options
  static const List<String> parityOptions = ['None', 'Even', 'Odd'];

  // Stop Bits Options
  static const List<String> stopBitsOptions = ['1', '1.5', '2'];

  // Baud Rate Options
  static const List<int> baudRateOptions = [9600, 19200, 38400, 57600, 115200];

  // Data Format Presets
  static const String format8N1 = '8N1';
  static const String format8E1 = '8E1';
  static const String format8O1 = '8O1';
}
