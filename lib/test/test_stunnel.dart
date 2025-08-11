import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Test script để kiểm tra Stunnel hoạt động
class StunnelTest {
  static const MethodChannel _channel = MethodChannel('stunnel_engine');
  
  /// Test Stunnel connection
  static Future<void> testStunnel() async {
    try {
      print('🧪 Testing Stunnel...');
      
      // Test config
      String config = '''
[wireguard]
verify = 0
client = yes
accept = 127.0.0.1:51820
connect = 144.126.138.95:443
''';
      
      // Start Stunnel
      print('🚀 Starting Stunnel...');
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
      
      // Wait 5 seconds
      await Future.delayed(Duration(seconds: 5));
      
      // Stop Stunnel
      print('🛑 Stopping Stunnel...');
      final bool stopResult = await _channel.invokeMethod('stopStunnel');
      print('Stop result: $stopResult');
      
      print('✅ Stunnel test completed!');
      
    } catch (e) {
      print('❌ Stunnel test failed: $e');
    }
  }
}

/// Widget để test Stunnel
class StunnelTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stunnel Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => StunnelTest.testStunnel(),
              child: Text('Test Stunnel'),
            ),
            SizedBox(height: 20),
            Text('Kiểm tra console để xem kết quả test'),
          ],
        ),
      ),
    );
  }
} 