package com.example.flutter_application

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/native_serial"
    private lateinit var serialHandler: NativeSerialHandler
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        serialHandler = NativeSerialHandler()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAvailablePorts" -> {
                        val ports = serialHandler.getAvailablePorts()
                        result.success(ports)
                    }
                    
                    "openPort" -> {
                        val path = call.argument<String>("path") ?: ""
                        val baudRate = call.argument<Int>("baudRate") ?: 9600
                        val dataBits = call.argument<Int>("dataBits") ?: 8
                        val stopBits = call.argument<Int>("stopBits") ?: 1
                        val parity = call.argument<Int>("parity") ?: 0
                        
                        val success = serialHandler.openPort(
                            path, baudRate, dataBits, stopBits, parity
                        )
                        result.success(success)
                    }
                    
                    "write" -> {
                        val data = call.argument<ByteArray>("data")
                        if (data != null) {
                            val success = serialHandler.write(data)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGUMENT", "Data cannot be null", null)
                        }
                    }
                    
                    "read" -> {
                        val timeout = call.argument<Int>("timeout") ?: 1000
                        val data = serialHandler.read(timeout)
                        result.success(data)
                    }
                    
                    "closePort" -> {
                        serialHandler.closePort()
                        result.success(true)
                    }
                    
                    "isOpen" -> {
                        val isOpen = serialHandler.isOpen()
                        result.success(isOpen)
                    }
                    
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
