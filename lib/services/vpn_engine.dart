import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import '../models/vpn_status.dart';
import '../models/vpn_config.dart';

/// Exception thrown when VPN operations fail
class VpnException implements Exception {
  final String message;
  final String? code;
  
  const VpnException(this.message, [this.code]);
  
  @override
  String toString() => 'VpnException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Manages VPN connections through platform channels
/// Supports both OpenVPN and WireGuard protocols
class VpnEngine {
  /// Private constructor to prevent instantiation
  VpnEngine._();
  
  // Channel names for communication with native platform
  static const String _eventChannelVpnStage = "vpnStage";
  static const String _eventChannelVpnStatus = "vpnStatus";
  static const String _methodChannelVpnControl = "vpnControl";
  
  // Cached method channel instance
  static final MethodChannel _methodChannel = MethodChannel(_methodChannelVpnControl);
  
  /// Stream of VPN connection stage changes
  /// Returns a stream of stage strings (e.g., "connected", "disconnected")
  static Stream<String> vpnStageSnapshot() {
    return EventChannel(_eventChannelVpnStage)
        .receiveBroadcastStream()
        .cast<String>()
        .handleError((error) {
          log('VPN Stage Stream Error: $error');
          throw VpnException('Failed to get VPN stage updates: $error');
        });
  }

  /// Stream of detailed VPN status updates
  /// Returns a stream of VpnStatus objects with connection details
  static Stream<VpnStatus?> vpnStatusSnapshot() {
    return EventChannel(_eventChannelVpnStatus)
        .receiveBroadcastStream()
        .map((event) {
          try {
            return VpnStatus.fromJson(jsonDecode(event));
          } catch (e) {
            log('Failed to parse VPN status: $e');
            return null;
          }
        })
        .cast<VpnStatus?>()
        .handleError((error) {
          log('VPN Status Stream Error: $error');
          throw VpnException('Failed to get VPN status updates: $error');
        });
  }

  /// Starts VPN connection with the provided configuration
  /// 
  /// [vpnConfig] - Configuration object containing connection details
  /// 
  /// Throws [VpnException] if the connection fails to start
  static Future<void> startVpn(VpnConfig vpnConfig) async {
    try {
      log('Starting VPN with config: ${vpnConfig.country}');
      await _methodChannel.invokeMethod("start", {
        "config": vpnConfig.config,
        "country": vpnConfig.country,
        "username": vpnConfig.username,
        "password": vpnConfig.password,
      });
    } on PlatformException catch (e) {
      log('Failed to start VPN: ${e.message}');
      throw VpnException('Failed to start VPN: ${e.message}', e.code);
    }
  }

  /// Stops the current VPN connection
  /// 
  /// Throws [VpnException] if the connection fails to stop
  static Future<void> stopVpn() async {
    try {
      await _methodChannel.invokeMethod("stop");
      log('VPN stopped successfully');
    } on PlatformException catch (e) {
      log('Failed to stop VPN: ${e.message}');
      throw VpnException('Failed to stop VPN: ${e.message}', e.code);
    }
  }

  /// Opens the VPN kill switch settings
  /// 
  /// Throws [VpnException] if unable to open settings
  static Future<void> openKillSwitch() async {
    try {
      await _methodChannel.invokeMethod("kill_switch");
    } on PlatformException catch (e) {
      log('Failed to open kill switch: ${e.message}');
      throw VpnException('Failed to open kill switch: ${e.message}', e.code);
    }
  }

  /// Triggers a refresh of the VPN connection stage
  /// 
  /// Throws [VpnException] if refresh fails
  static Future<void> refreshStage() async {
    try {
      await _methodChannel.invokeMethod("refresh");
    } on PlatformException catch (e) {
      log('Failed to refresh stage: ${e.message}');
      throw VpnException('Failed to refresh stage: ${e.message}', e.code);
    }
  }

  /// Gets the current VPN connection stage
  /// 
  /// Returns the current stage as a string, or null if unavailable
  static Future<String?> stage() async {
    try {
      return await _methodChannel.invokeMethod<String>("stage");
    } on PlatformException catch (e) {
      log('Failed to get stage: ${e.message}');
      throw VpnException('Failed to get stage: ${e.message}', e.code);
    }
  }

  /// Checks if VPN is currently connected
  /// 
  /// Returns true if connected, false otherwise
  static Future<bool> isConnected() async {
    try {
      final currentStage = await stage();
      return currentStage?.toLowerCase() == vpnConnected;
    } catch (e) {
      log('Failed to check connection status: $e');
      return false;
    }
  }

  /// Starts WireGuard VPN with the provided configuration
  /// 
  /// [name] - Name for the WireGuard tunnel
  /// [config] - WireGuard configuration string
  /// 
  /// Returns true if started successfully, false otherwise
  static Future<bool> startWireGuard(String name, String config) async {
    if (name.isEmpty || config.isEmpty) {
      throw VpnException('WireGuard name and config cannot be empty');
    }
    
    try {
      final result = await _methodChannel.invokeMethod('startWireGuard', {
        'name': name,
        'config': config,
      });
      log('WireGuard start result: $result');
      return result == true;
    } on PlatformException catch (e) {
      log('Failed to start WireGuard: ${e.message}');
      throw VpnException('Failed to start WireGuard: ${e.message}', e.code);
    }
  }

  /// Stops WireGuard VPN connection
  /// 
  /// Returns true if stopped successfully, false otherwise
  static Future<bool> stopWireGuard() async {
    try {
      final result = await _methodChannel.invokeMethod('stopWireGuard');
      log('WireGuard stop result: $result');
      return result == true;
    } on PlatformException catch (e) {
      log('Failed to stop WireGuard: ${e.message}');
      throw VpnException('Failed to stop WireGuard: ${e.message}', e.code);
    }
  }

  /// Gets the current WireGuard VPN state
  /// 
  /// Returns the current state as a string (e.g., "UP", "DOWN", "UNKNOWN")
  static Future<String> getWireGuardState() async {
    try {
      final result = await _methodChannel.invokeMethod('getWireGuardState');
      return result?.toString() ?? wireGuardStateUnknown;
    } on PlatformException catch (e) {
      log('Failed to get WireGuard state: ${e.message}');
      return wireGuardStateUnknown;
    }
  }

  /// Checks if WireGuard VPN is currently connected
  /// 
  /// Returns true if WireGuard is up and running
  static Future<bool> isWireGuardConnected() async {
    try {
      final state = await getWireGuardState();
      return state.toLowerCase() == 'up';
    } catch (e) {
      log('Failed to check WireGuard connection: $e');
      return false;
    }
  }

  // OpenVPN Connection Stages
  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
  
  // WireGuard States
  static const String wireGuardStateUp = "UP";
  static const String wireGuardStateDown = "DOWN";
  static const String wireGuardStateUnknown = "UNKNOWN";
  
  /// Returns a list of all possible VPN stages
  static List<String> get allVpnStages => [
    vpnConnected,
    vpnDisconnected,
    vpnWaitConnection,
    vpnAuthenticating,
    vpnReconnect,
    vpnNoConnection,
    vpnConnecting,
    vpnPrepare,
    vpnDenied,
  ];
  
  /// Returns a list of all possible WireGuard states
  static List<String> get allWireGuardStates => [
    wireGuardStateUp,
    wireGuardStateDown,
    wireGuardStateUnknown,
  ];
  
  /// Checks if a given stage represents a connected state
  static bool isStageConnected(String stage) {
    return stage.toLowerCase() == vpnConnected;
  }
  
  /// Checks if a given stage represents a connecting state
  static bool isStageConnecting(String stage) {
    final connectingStages = [
      vpnConnecting,
      vpnPrepare,
      vpnAuthenticating,
      vpnWaitConnection,
    ];
    return connectingStages.contains(stage.toLowerCase());
  }
  
  /// Checks if a given stage represents a disconnected state
  static bool isStageDisconnected(String stage) {
    final disconnectedStages = [
      vpnDisconnected,
      vpnNoConnection,
      vpnDenied,
    ];
    return disconnectedStages.contains(stage.toLowerCase());
  }
}