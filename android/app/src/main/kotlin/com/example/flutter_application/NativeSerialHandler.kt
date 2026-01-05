package com.example.flutter_application

import java.io.*
import java.nio.file.Files
import java.nio.file.Paths

/**
 * Native serial port handler for accessing /dev/ttyS* ports
 * Uses file I/O to read/write serial data
 */
class NativeSerialHandler {
    private var inputStream: FileInputStream? = null
    private var outputStream: FileOutputStream? = null
    private var currentPort: String? = null
    
    /**
     * Get list of available serial ports
     */
    fun getAvailablePorts(): List<String> {
        val potentialPorts = listOf(
            "/dev/ttyS1",
            "/dev/ttyS3", 
            "/dev/ttyS7",
            "/dev/ttyS9"
        )
        
        return potentialPorts.filter { 
            try {
                Files.exists(Paths.get(it))
            } catch (e: Exception) {
                false
            }
        }
    }
    
    /**
     * Open serial port with configuration
     * Requires root access
     */
    fun openPort(
        path: String, 
        baudRate: Int,
        dataBits: Int = 8,
        stopBits: Int = 1,
        parity: Int = 0 // 0=None, 1=Odd, 2=Even
    ): Boolean {
        try {
            // Close any existing connection
            closePort()
            
            // Set file permissions (requires root)
            val chmodCmd = "chmod 666 $path"
            Runtime.getRuntime().exec(arrayOf("su", "-c", chmodCmd)).waitFor()
            
            // Configure port using stty
            val parityStr = when (parity) {
                1 -> "parenb parodd"
                2 -> "parenb -parodd"
                else -> "-parenb"
            }
            
            val stopBitsStr = if (stopBits == 2) "cstopb" else "-cstopb"
            
            val sttyCmd = "stty -F $path $baudRate cs$dataBits $stopBitsStr $parityStr raw -echo"
            Runtime.getRuntime().exec(arrayOf("su", "-c", sttyCmd)).waitFor()
            
            // Open file streams
            inputStream = FileInputStream(path)
            outputStream = FileOutputStream(path)
            currentPort = path
            
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            closePort()
            return false
        }
    }
    
    /**
     * Write data to serial port
     */
    fun write(data: ByteArray): Boolean {
        return try {
            outputStream?.write(data)
            outputStream?.flush()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    /**
     * Read available data from serial port
     */
    fun read(timeoutMs: Int): ByteArray {
        val buffer = ByteArray(4096)
        
        return try {
            val startTime = System.currentTimeMillis()
            
            // Wait for data or timeout
            while (System.currentTimeMillis() - startTime < timeoutMs) {
                val available = inputStream?.available() ?: 0
                if (available > 0) {
                    val bytesToRead = minOf(available, buffer.size)
                    val bytesRead = inputStream?.read(buffer, 0, bytesToRead) ?: 0
                    return buffer.copyOf(bytesRead)
                }
                Thread.sleep(10) // Small delay to prevent busy waiting
            }
            
            byteArrayOf() // Timeout
        } catch (e: Exception) {
            e.printStackTrace()
            byteArrayOf()
        }
    }
    
    /**
     * Close serial port
     */
    fun closePort() {
        try {
            inputStream?.close()
            outputStream?.close()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            inputStream = null
            outputStream = null
            currentPort = null
        }
    }
    
    /**
     * Check if port is open
     */
    fun isOpen(): Boolean {
        return inputStream != null && outputStream != null
    }
    
    /**
     * Get current port path
     */
    fun getCurrentPort(): String? {
        return currentPort
    }
}
