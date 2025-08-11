import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Test script để kiểm tra Stunnel binary thực
class StunnelBinaryTest {
  static const MethodChannel _channel = MethodChannel('stunnel_engine');
  
  /// Test Stunnel binary thực
  static Future<void> testStunnelBinary() async {
    try {
      print('🧪 Testing Stunnel Binary...');
      
      // Test config
      String config = '''
[wireguard]
verify = 0
client = yes
accept = 127.0.0.1:51820
connect = 144.126.138.95:443
''';
      
      // Start Stunnel
      print('🚀 Starting Stunnel with real binary...');
      final bool startResult = await _channel.invokeMethod('startStunnel', {
        'configPath': config,
      });
      
      print('Start result: $startResult');
      
      // Check status
      final String status = await _channel.invokeMethod('getStunnelStatus');
      print('Status: $status');
      
      // Check if running
      final bool isRunning = await _channel.invokeMethod('isStunnelRunning');
      print('Is running: $isRunning');
      
      // Get info
      final Map<dynamic, dynamic> info = await _channel.invokeMethod('getStunnelInfo');
      print('Info: $info');
      
      // Wait 5 seconds
      await Future.delayed(Duration(seconds: 5));
      
      // Stop Stunnel
      print('🛑 Stopping Stunnel...');
      final bool stopResult = await _channel.invokeMethod('stopStunnel');
      print('Stop result: $stopResult');
      
      print('✅ Stunnel binary test completed!');
      
    } catch (e) {
      print('❌ Stunnel binary test failed: $e');
    }
  }
  
  /// Test binary detection
  static Future<void> testBinaryDetection() async {
    try {
      print('🔍 Testing Binary Detection...');
      
      // Test với config đơn giản
      String config = '''
[test]
client = yes
accept = 127.0.0.1:51821
connect = 127.0.0.1:51822
''';
      
      final bool startResult = await _channel.invokeMethod('startStunnel', {
        'configPath': config,
      });
      
      print('Binary detection result: $startResult');
      
      // Stop
      await _channel.invokeMethod('stopStunnel');
      
    } catch (e) {
      print('❌ Binary detection test failed: $e');
    }
  }
}

/// Widget để test Stunnel binary
class StunnelBinaryTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stunnel Binary Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => StunnelBinaryTest.testStunnelBinary(),
              child: Text('Test Stunnel Binary'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => StunnelBinaryTest.testBinaryDetection(),
              child: Text('Test Binary Detection'),
            ),
            SizedBox(height: 20),
            Text('Kiểm tra console để xem kết quả test'),
            SizedBox(height: 10),
            Text('Binary size: 102400 bytes (100KB)'),
            Text('Expected: Real binary detection'),
          ],
        ),
      ),
    );
  }
} 