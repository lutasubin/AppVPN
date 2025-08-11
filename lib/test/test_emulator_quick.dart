import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quick test script cho máy ảo Android
class EmulatorQuickTest {
  static const MethodChannel _channel = MethodChannel('stunnel_engine');
  
  /// Test nhanh Stunnel trên máy ảo
  static Future<void> quickTest() async {
    try {
      print('🚀 Quick Test trên Máy ảo...');
      
      // Test config đơn giản
      String config = '''
[test]
client = yes
accept = 127.0.0.1:51820
connect = 144.126.138.95:443
''';
      
      print('📋 Testing Binary Detection...');
      
      // Test binary detection
      final bool startResult = await _channel.invokeMethod('startStunnel', {
        'configPath': config,
      });
      
      print('✅ Start result: $startResult');
      
      // Check status
      final String status = await _channel.invokeMethod('getStunnelStatus');
      print('📊 Status: $status');
      
      // Check if running
      final bool isRunning = await _channel.invokeMethod('isStunnelRunning');
      print('🔄 Is running: $isRunning');
      
      // Get info
      final Map<dynamic, dynamic> info = await _channel.invokeMethod('getStunnelInfo');
      print('ℹ️ Info: $info');
      
      // Wait 3 seconds
      print('⏳ Waiting 3 seconds...');
      await Future.delayed(Duration(seconds: 3));
      
      // Stop
      print('🛑 Stopping...');
      final bool stopResult = await _channel.invokeMethod('stopStunnel');
      print('✅ Stop result: $stopResult');
      
      print('🎉 Quick test completed!');
      
    } catch (e) {
      print('❌ Quick test failed: $e');
    }
  }
  
  /// Test performance
  static Future<void> performanceTest() async {
    try {
      print('⚡ Performance Test...');
      
      String config = '''
[perf]
client = yes
accept = 127.0.0.1:51821
connect = 144.126.138.95:443
''';
      
      final stopwatch = Stopwatch()..start();
      
      // Start Stunnel
      final bool startResult = await _channel.invokeMethod('startStunnel', {
        'configPath': config,
      });
      
      stopwatch.stop();
      
      print('⏱️ Start time: ${stopwatch.elapsedMilliseconds}ms');
      print('✅ Start result: $startResult');
      
      // Wait
      await Future.delayed(Duration(seconds: 2));
      
      // Stop
      stopwatch.reset();
      stopwatch.start();
      
      final bool stopResult = await _channel.invokeMethod('stopStunnel');
      
      stopwatch.stop();
      
      print('⏱️ Stop time: ${stopwatch.elapsedMilliseconds}ms');
      print('✅ Stop result: $stopResult');
      
    } catch (e) {
      print('❌ Performance test failed: $e');
    }
  }
  
  /// Test error handling
  static Future<void> errorTest() async {
    try {
      print('🔍 Error Handling Test...');
      
      // Test với config sai
      String badConfig = '''
[bad]
client = yes
accept = invalid:port
connect = invalid:port
''';
      
      final bool startResult = await _channel.invokeMethod('startStunnel', {
        'configPath': badConfig,
      });
      
      print('✅ Error handling result: $startResult');
      
      // Stop
      await _channel.invokeMethod('stopStunnel');
      
    } catch (e) {
      print('❌ Error test failed: $e');
    }
  }
}

/// Widget test nhanh cho máy ảo
class EmulatorQuickTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emulator Quick Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '🧪 Stunnel Test trên Máy ảo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Binary size: 102400 bytes (100KB)'),
                    Text('Architecture: x86_64'),
                    Text('Expected: Real binary detection'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => EmulatorQuickTest.quickTest(),
              child: Text('🚀 Quick Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => EmulatorQuickTest.performanceTest(),
              child: Text('⚡ Performance Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => EmulatorQuickTest.errorTest(),
              child: Text('🔍 Error Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Kiểm tra console để xem kết quả test',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'adb logcat | grep StunnelEngine',
              style: TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.black,
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 