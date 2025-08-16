import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vpn_basic_project/apis/wireguard_service.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/services/stunnel_engine.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';

/// Dịch vụ kết nối VPN với các giao thức khác nhau - ENHANCED VERSION WITH CLIENT CLEANUP
class VpnConnectionService {
  // ===========================================
  // PRIVATE PROPERTIES
  // ===========================================

  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3;

  // WireGuard service instance
  final WireGuardService _wireGuardService = WireGuardService();
  
  // ✅ NEW: Track active client name for cleanup
  String? _activeClientName;
  String? _activeServerProtocol;

  // ===========================================
  // CALLBACKS
  // ===========================================

  Function(String, dynamic)? onError;
  Function()? onRetryAttempt;
  
  // ✅ NEW: Add the missing callback properties
  Function(String clientName, String protocol, String serverId)? onClientCreated;
  Function(String clientName)? onClientCleanupNeeded;

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
      
      // ✅ Clear previous client info
      _activeClientName = null;
      _activeServerProtocol = null;
      
      if (server != null) {
        await _connectBasedOnProtocol(server, apiVpn);
      } else if (isApiVpnServer || server == null) {
        await _connectOpenVPN(apiVpn);
      } else {
        throw Exception('No valid server configuration found');
      }
    } catch (e) {
      print("❌ Connection failed: $e");
      
      // ✅ Clean up client on connection failure
      await _cleanupClientOnError();
      
      _handleConnectionError('Connection failed', e);
      rethrow;
    }
  }

  /// ✅ ENHANCED: Disconnect VPN with client cleanup
  Future<void> disconnectVpn({
    required LocalVpnServer? server,
    required Vpn apiVpn,
    required bool isApiVpnServer,
    int? connectionDuration,
  }) async {
    try {
      print('🔥 VpnConnectionService.disconnectVpn() CALLED');
      print('- isApiVpnServer: $isApiVpnServer');
      print('- server: ${server?.countryName} (${server?.protocol})');
      print('- connectionDuration: $connectionDuration');
      print('- activeClientName: $_activeClientName');

      // ✅ STEP 1: Store client info for cleanup BEFORE stopping VPN
      String? clientToCleanup = _activeClientName;
      String? protocolToCleanup = _activeServerProtocol;
      
      // STEP 2: Stop VPN tunnel FIRST (traditional approach)
      if (isApiVpnServer) {
        print('🔄 Stopping API VPN...');
        await _stopVpnWithOptimizedTimeout(
            () => VpnEngine.stopVpn(), 'API VPN', 5);
        _logAnalytics(
            () => AnalyticsHelper.logVpnDisconnect(
                apiVpn.CountryLong, connectionDuration ?? 0),
            'API VPN');
      } else if (server != null && server.protocol == 'stunnel-wireguard') {
        print('🔄 Stopping Stunnel+WireGuard...');

        // Stop WireGuard first (usually faster)
        await _stopVpnWithOptimizedTimeout(
            () => VpnEngine.stopWireGuard(), 'WireGuard', 3);

        // Then stop Stunnel
        await _stopVpnWithOptimizedTimeout(
            () => StunnelEngine.stopStunnel(), 'Stunnel', 3);

        _logAnalytics(
            () => AnalyticsHelper.logVpnDisconnect(
                server.countryName, connectionDuration ?? 0),
            'Stunnel+WireGuard');
      } else if (server != null &&
          (server.protocol == 'wireguard' ||
              server.protocol == 'wireguard-api')) {
        print('🔄 Stopping WireGuard (${server.protocol})...');
        await _stopVpnWithOptimizedTimeout(
            () => VpnEngine.stopWireGuard(), 'WireGuard', 3);
        _logAnalytics(
            () => AnalyticsHelper.logVpnDisconnect(
                server.countryName, connectionDuration ?? 0),
            'WireGuard');
      } else {
        print('🔄 Stopping OpenVPN (default)...');
        // OpenVPN thường mất nhiều thời gian hơn, nhưng giảm timeout để UX tốt hơn
        await _stopVpnWithOptimizedTimeout(
            () => VpnEngine.stopVpn(), 'OpenVPN', 5);

        String serverName = server?.countryName ?? apiVpn.CountryLong;
        _logAnalytics(
            () => AnalyticsHelper.logVpnDisconnect(
                serverName, connectionDuration ?? 0),
            'OpenVPN');
      }

      // ✅ STEP 3: Clean up client from server AFTER stopping VPN
      await _cleanupWireGuardClientAfterStop(server, isApiVpnServer, clientToCleanup, protocolToCleanup);

      // STEP 4: Clear tracking info
      _clearClientInfo();

      print('🎉 VpnConnectionService.disconnectVpn() COMPLETED SUCCESSFULLY');
    } catch (e) {
      print('❌ VpnConnectionService.disconnectVpn() ERROR: $e');
      
      // ✅ Still try to cleanup on error
      await _cleanupClientOnError();
      
      _handleError('Failed to disconnect VPN', e);
      rethrow;
    }
  }

  /// ✅ NEW: Clean up WireGuard client from server AFTER stopping VPN
  Future<void> _cleanupWireGuardClientAfterStop(
    LocalVpnServer? server, 
    bool isApiVpnServer, 
    String? clientToCleanup,
    String? protocolToCleanup
  ) async {
    // Only cleanup for WireGuard API connections
    if (server?.protocol == 'wireguard-api' && clientToCleanup != null) {
      print('🗑️ Cleaning up WireGuard API client: $clientToCleanup');
      
      // ✅ Trigger callback before cleanup
      onClientCleanupNeeded?.call(clientToCleanup);
      
      try {
        final success = await _wireGuardService.removeClientFromServer(clientToCleanup);
        if (success) {
          print('✅ Client cleanup successful');
        } else {
          print('⚠️ Client cleanup failed, but VPN already stopped');
        }
      } catch (e) {
        print('⚠️ Client cleanup error (VPN already stopped): $e');
        // Don't throw - cleanup failure after VPN stop shouldn't fail the disconnect
      }
    } else if (clientToCleanup != null) {
      print('ℹ️ Skipping client cleanup for protocol: ${server?.protocol ?? 'unknown'}');
    } else {
      print('ℹ️ No client to cleanup');
    }
  }

  /// ✅ NEW: Clean up client on error
  Future<void> _cleanupClientOnError() async {
    if (_activeClientName != null && _activeServerProtocol == 'wireguard-api') {
      print('🗑️ Emergency cleanup for client: $_activeClientName');
      
      // ✅ NEW: Trigger callback before emergency cleanup
      onClientCleanupNeeded?.call(_activeClientName!);
      
      try {
        await _wireGuardService.removeClientFromServer(_activeClientName!);
        print('✅ Emergency cleanup successful');
      } catch (e) {
        print('⚠️ Emergency cleanup failed: $e');
        // Don't throw - this is cleanup after an error
      }
      
      _clearClientInfo();
    }
  }

  /// ✅ NEW: Clear client tracking info
  void _clearClientInfo() {
    _activeClientName = null;
    _activeServerProtocol = null;
    print('🧹 Client info cleared');
  }

  /// Stop VPN with optimized timeout for better UX
  Future<void> _stopVpnWithOptimizedTimeout(
      Future<void> Function() stopFunction,
      String serviceName,
      int timeoutSeconds) async {
    try {
      print('⏰ Starting $serviceName stop with ${timeoutSeconds}s timeout...');

      await stopFunction().timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          print(
              '⚠️ $serviceName stop timed out after ${timeoutSeconds}s - continuing for better UX');
          // Không throw exception, chỉ log để UX mượt hơn
        },
      );

      print('✅ $serviceName stop completed');
    } catch (e) {
      if (e is TimeoutException) {
        print('⏰ $serviceName timeout handled gracefully');
      } else {
        print('⚠️ $serviceName stop error (continuing): $e');
      }
      // Không rethrow để không block UI flow
    }
  }

  /// Log analytics without blocking main flow
  void _logAnalytics(Function() analyticsFunction, String serviceName) {
    try {
      analyticsFunction();
      print('📊 Analytics logged for $serviceName');
    } catch (e) {
      print('⚠️ Analytics warning for $serviceName: $e');
      // Không rethrow - analytics failure không nên block disconnect flow
    }
  }

  /// ✅ ENHANCED: Handle connection timeout with client cleanup
  Future<void> handleConnectionTimeout({
    required LocalVpnServer? server,
    required Vpn apiVpn,
    required bool isApiVpnServer,
  }) async {
    try {
      print('🔄 Auto-disconnecting due to timeout');

      // ✅ Clean up client first
      await _cleanupWireGuardClientAfterStop(server, isApiVpnServer, _activeClientName, _activeServerProtocol);

      if (isApiVpnServer) {
        print('wait stop');
        await VpnEngine.stopVpn();
        print(' stop vpn');
      } else if (server != null && server.protocol == 'stunnel-wireguard') {
        await VpnEngine.stopWireGuard();
        await StunnelEngine.stopStunnel();
      } else if (server != null &&
          (server.protocol == 'wireguard' ||
              server.protocol == 'wireguard-api')) {
        await VpnEngine.stopWireGuard();
      } else {
        await VpnEngine.stopVpn();
      }

      // ✅ Clear tracking info
      _clearClientInfo();

      print('✅ VPN stopped due to timeout');
    } catch (e) {
      print('❌ Error stopping VPN on timeout: $e');
      await _cleanupClientOnError();
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

  /// ✅ ENHANCED: Connect to WireGuard VPN from API with client tracking
  Future<void> _connectWireGuardFromApi(LocalVpnServer server) async {
    try {
      print('🌐 Connecting to WireGuard via API...');

      // 1. Get validated config content directly from API (no file saving)
      final configData = await _wireGuardService.getConfigDataWithClientName();

      if (configData == null || configData['config'] == null || configData['config'].isEmpty) {
        throw Exception('Failed to get valid WireGuard config from API');
      }

      final String configContent = configData['config'];
      final String? clientName = configData['clientName'];

      // ✅ Store client info for cleanup
      _activeClientName = clientName;
      _activeServerProtocol = 'wireguard-api';

      // ✅ NEW: Trigger callback after client creation
      if (_activeClientName != null) {
        onClientCreated?.call(_activeClientName!, 'wireguard-api', server.countryCode);
      }

      print('📋 WireGuard config loaded from API');
      print('👤 Client name: $_activeClientName');
      print('Config size: ${configContent.length} characters');

      // 2. Log first few lines for debugging (safe)
      final lines = configContent.split('\n');
      print('🔍 Config structure:');
      for (int i = 0; i < 5 && i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          // Don't log private keys or sensitive data
          if (lines[i].contains('PrivateKey') ||
              lines[i].contains('PublicKey') ||
              lines[i].contains('PresharedKey')) {
            print('  ${lines[i].split('=')[0]}=***HIDDEN***');
          } else {
            print('  ${lines[i]}');
          }
        }
      }

      // 3. Start WireGuard tunnel with config content
      final success =
          await VpnEngine.startWireGuard('wg-api-tunnel', configContent);

      if (!success) {
        throw Exception('Failed to start WireGuard API tunnel');
      }

      print('✅ WireGuard API tunnel started successfully');
      AnalyticsHelper.logVpnConnect(server.countryName, server.countryCode);

      print('🎉 WireGuard API connection completed with client tracking');
    } catch (e) {
      print('❌ WireGuard API connection failed: $e');

      // ✅ Clean up on connection failure
      await _cleanupClientOnError();

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