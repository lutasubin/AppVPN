import 'dart:async';
import 'package:flutter/services.dart';

/// Service để quản lý Stunnel tunnel
class StunnelEngine {
  static const MethodChannel _channel = MethodChannel('stunnel_engine');
  static const EventChannel _eventChannel = EventChannel('stunnel_status');
  
  // Trạng thái Stunnel
  static const String stunnelDisconnected = 'disconnected';
  static const String stunnelConnecting = 'connecting';
  static const String stunnelConnected = 'connected';
  static const String stunnelError = 'error';

  /// Khởi động Stunnel tunnel
  static Future<bool> startStunnel(String configPath) async {
    try {
      final bool result = await _channel.invokeMethod('startStunnel', {
        'configPath': configPath,
      });
      return result;
    } on PlatformException catch (e) {
      print('StunnelEngine Error: ${e.message}');
      return false;
    }
  }

  /// Dừng Stunnel tunnel
  static Future<bool> stopStunnel() async {
    try {
      final bool result = await _channel.invokeMethod('stopStunnel');
      return result;
    } on PlatformException catch (e) {
      print('StunnelEngine Error: ${e.message}');
      return false;
    }
  }

  /// Lấy trạng thái hiện tại của Stunnel
  static Future<String> getStunnelStatus() async {
    try {
      final String status = await _channel.invokeMethod('getStunnelStatus');
      return status;
    } on PlatformException catch (e) {
      print('StunnelEngine Error: ${e.message}');
      return stunnelError;
    }
  }

  /// Stream để lắng nghe thay đổi trạng thái Stunnel
  static Stream<String> stunnelStatusStream() {
    return _eventChannel.receiveBroadcastStream()
        .map((event) => event.toString());
  }

  /// Kiểm tra xem Stunnel có đang chạy không
  static Future<bool> isStunnelRunning() async {
    try {
      final bool isRunning = await _channel.invokeMethod('isStunnelRunning');
      return isRunning;
    } on PlatformException catch (e) {
      print('StunnelEngine Error: ${e.message}');
      return false;
    }
  }

  /// Lấy thông tin về Stunnel process
  static Future<Map<String, dynamic>> getStunnelInfo() async {
    try {
      final Map<dynamic, dynamic> info = await _channel.invokeMethod('getStunnelInfo');
      return Map<String, dynamic>.from(info);
    } on PlatformException catch (e) {
      print('StunnelEngine Error: ${e.message}');
      return {};
    }
  }
} 