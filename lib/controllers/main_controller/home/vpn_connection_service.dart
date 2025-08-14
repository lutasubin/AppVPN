import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vpn_basic_project/apis/wireguard_api.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/services/stunnel_engine.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';

/// Dịch vụ kết nối VPN với các giao thức khác nhau - FIXED VERSION
class VpnConnectionService {
  // ===========================================
  // PRIVATE PROPERTIES
  // ===========================================

  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3;
  
  // WireGuard service instance
  final WireGuardService _wireGuardService = WireGuardService();

  // ===========================================
  // CALLBACKS
  // ===========================================

  Function(String, dynamic)? onError;
  Function()? onRetryAttempt;

  // ===========================================
  // PUBLIC METHODS
  // ===========================================

  /// Connect to VPN based on server type and protocol
  Future<void> connectToVpn({
    required LocalVpnServer? server,
    required Vpn apiVpn,
    required bool isApiVpnServer,
  }) async {
    try {
      _retryAttempts = 0;
      if (server != null) {
        await _connectBasedOnProtocol(server, apiVpn);
      } else if (isApiVpnServer || server == null) {
        await _connectOpenVPN(apiVpn);
      } else {
        throw Exception('No valid server configuration found');
      }
    } catch (e) {
      print("❌ Connection failed: $e");
      _handleConnectionError('Connection failed', e);
      rethrow;
    }
  }

  /// Disconnect VPN based on current configuration
  Future<void> disconnectVpn({
    required LocalVpnServer? server,
    required Vpn apiVpn,
    required bool isApiVpnServer,
    int? connectionDuration,
  }) async {
    try {
      if (isApiVpnServer) {
        await VpnEngine.stopVpn();
        AnalyticsHelper.logVpnDisconnect(
            apiVpn.CountryLong, connectionDuration ?? 0);
      } else if (server != null && server.protocol == 'stunnel-wireguard') {
        await VpnEngine.stopWireGuard();
        await StunnelEngine.stopStunnel();
        await AnalyticsHelper.logVpnDisconnect(
            server.countryName, connectionDuration ?? 0);
      } else if (server != null && (server.protocol == 'wireguard' || server.protocol == 'wireguard-api')) {
        await VpnEngine.stopWireGuard();
        await AnalyticsHelper.logVpnDisconnect(
            server.countryName, connectionDuration ?? 0);
      } else {
        await VpnEngine.stopVpn();
        String serverName = server?.countryName ?? apiVpn.CountryLong;
        await AnalyticsHelper.logVpnDisconnect(
            serverName, connectionDuration ?? 0);
      }

      // Cleanup config files
      await _wireGuardService.cleanup();
      
    } catch (e) {
      _handleError('Failed to disconnect VPN', e);
      rethrow;
    }
  }

  /// Handle connection timeout by stopping VPN
  Future<void> handleConnectionTimeout({
    required LocalVpnServer? server,
    required Vpn apiVpn,
    required bool isApiVpnServer,
  }) async {
    try {
      print('🔄 Auto-disconnecting due to timeout');

      if (isApiVpnServer) {
        await VpnEngine.stopVpn();
      } else if (server != null && server.protocol == 'stunnel-wireguard') {
        await VpnEngine.stopWireGuard();
        await StunnelEngine.stopStunnel();
      } else if (server != null && (server.protocol == 'wireguard' || server.protocol == 'wireguard-api')) {
        await VpnEngine.stopWireGuard();
      } else {
        await VpnEngine.stopVpn();
      }

      await _wireGuardService.cleanup();
      print('✅ VPN stopped due to timeout');
    } catch (e) {
      print('❌ Error stopping VPN on timeout: $e');
      _handleError('Failed to stop VPN on timeout', e);
    }
  }

  /// Retry connection if attempts are available
  bool canRetryConnection() {
    return _retryAttempts < _maxRetryAttempts;
  }

  /// Increment retry attempts
  void incrementRetryAttempts() {
    _retryAttempts++;
    onRetryAttempt?.call();
  }

  /// Reset retry attempts
  void resetRetryAttempts() {
    _retryAttempts = 0;
  }

  /// Get current retry attempts
  int get retryAttempts => _retryAttempts;
  int get maxRetryAttempts => _maxRetryAttempts;

  // ===========================================
  // PRIVATE METHODS
  // ===========================================

  /// Connect based on server protocol
  Future<void> _connectBasedOnProtocol(
      LocalVpnServer server, Vpn apiVpn) async {
    switch (server.protocol) {
      case 'stunnel-wireguard':
        await _connectStunnelWireGuard(server);
        break;
      case 'wireguard':
        await _connectWireGuard(server);
        break;
      case 'wireguard-api':
        await _connectWireGuardFromApi(server);
        break;
      default:
        await _connectOpenVPN(apiVpn);
    }
  }

  /// Connect to WireGuard VPN from assets (existing method)
  Future<void> _connectWireGuard(LocalVpnServer server) async {
    try {
      final config = await rootBundle
          .loadString('assets/wireguard/${server.configFileName}');

      if (config.isEmpty) {
        throw Exception('WireGuard configuration is empty');
      }

      final success = await VpnEngine.startWireGuard('wg-tunnel', config);

      if (!success) {
        throw Exception('Failed to start WireGuard tunnel');
      }

      AnalyticsHelper.logVpnConnect(server.countryName, server.countryCode);
    } catch (e) {
      throw Exception('WireGuard connection failed: ${e.toString()}');
    }
  }

  /// ✅ FIXED: Connect to WireGuard VPN from API
  Future<void> _connectWireGuardFromApi(LocalVpnServer server) async {
    try {
      print('🌐 Connecting to WireGuard via API...');
      
      // 1. Get validated config from API
      final File? configFile = await _wireGuardService.getConfigForVPN();

      if (configFile == null || !await configFile.exists()) {
        throw Exception('Failed to get valid WireGuard config from API');
      }

      // 2. Read config content safely
      final String config = await configFile.readAsString(encoding: utf8);

      if (config.isEmpty) {
        throw Exception('WireGuard API configuration is empty');
      }

      print('📋 WireGuard config loaded from API');
      print('Config preview: ${config.length} characters');
      
      // 3. Log first few lines for debugging (safe)
      final lines = config.split('\n');
      print('🔍 Config structure:');
      for (int i = 0; i < 5 && i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          // Don't log private keys or sensitive data
          if (lines[i].contains('PrivateKey') || lines[i].contains('PublicKey')) {
            print('  ${lines[i].split('=')[0]}=***HIDDEN***');
          } else {
            print('  ${lines[i]}');
          }
        }
      }

      // 4. Start WireGuard tunnel with cleaned config
      final success = await VpnEngine.startWireGuard('wg-api-tunnel', config);

      if (!success) {
        await configFile.delete(); // Cleanup on failure
        throw Exception('Failed to start WireGuard API tunnel');
      }

      print('✅ WireGuard API tunnel started successfully');
      AnalyticsHelper.logVpnConnect(server.countryName, server.countryCode);
      
      // 5. Cleanup config file after successful connection
      try {
        await configFile.delete();
        print('🗑️ Config file cleaned up after connection');
      } catch (e) {
        print('⚠️ Warning: Could not delete config file: $e');
      }
      
    } catch (e) {
      print('❌ WireGuard API connection failed: $e');
      
      // Cleanup any remaining files on error
      await _wireGuardService.cleanup();
      
      throw Exception('WireGuard API connection failed: ${e.toString()}');
    }
  }

  /// Connect to Stunnel + WireGuard VPN
  Future<void> _connectStunnelWireGuard(LocalVpnServer server) async {
    try {
      // 1. Start Stunnel first
      final stunnelConfig = await rootBundle
          .loadString('assets/stunnel/${server.stunnelConfigFileName}');

      if (stunnelConfig.isEmpty) {
        throw Exception('Stunnel configuration is empty');
      }

      final stunnelSuccess = await StunnelEngine.startStunnel(stunnelConfig);
      if (!stunnelSuccess) {
        throw Exception('Failed to start Stunnel tunnel');
      }

      // 2. Wait for Stunnel to connect
      await Future.delayed(const Duration(seconds: 2));

      // 3. Start WireGuard over Stunnel
      final wireguardConfig = await rootBundle
          .loadString('assets/stunnel/${server.configFileName}');

      if (wireguardConfig.isEmpty) {
        throw Exception('WireGuard configuration is empty');
      }

      final wireguardSuccess =
          await VpnEngine.startWireGuard('wg-stunnel-tunnel', wireguardConfig);
      if (!wireguardSuccess) {
        throw Exception('Failed to start WireGuard tunnel over Stunnel');
      }
      AnalyticsHelper.logVpnConnect(server.countryName, server.countryCode);
    } catch (e) {
      // Cleanup on error
      await StunnelEngine.stopStunnel();
      throw Exception('Stunnel-WireGuard connection failed: ${e.toString()}');
    }
  }

  /// Connect to OpenVPN
  Future<void> _connectOpenVPN(Vpn vpn) async {
    if (vpn.OpenVPNConfigDataBase64.isEmpty) {
      throw Exception('Select a Location by clicking \'Change Location\'');
    }

    try {
      final data = Base64Decoder().convert(vpn.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
        country: vpn.CountryLong,
        username: '',
        password: '',
        config: config,
      );

      await VpnEngine.startVpn(vpnConfig);
      AnalyticsHelper.logVpnConnect(vpn.CountryLong, vpn.CountryShort);
    } catch (e) {
      throw Exception('OpenVPN connection failed: ${e.toString()}');
    }
  }

  /// Handle errors with consistent logging
  void _handleError(String message, dynamic error) {
    print('VpnConnectionService Error: $message - $error');
    onError?.call(message, error);
  }

  /// Handle connection-specific errors with retry logic
  void _handleConnectionError(String message, dynamic error) {
    _handleError(message, error);

    if (_retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;
      print(
          '🔁 Connection error, will retry... ($_retryAttempts/$_maxRetryAttempts)');
    } else {
      print('❌ Max retry attempts reached');
    }
  }
}