import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/helpers/dilogs/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/fake_data/upload_download.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/view/screens/connected/conected_screen.dart';
import 'package:vpn_basic_project/view/screens/disconnected/disconected_screen.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/watch_video_disconnect.dart';

// Import các manager đã tách
import 'vpn_state_manager.dart';
import 'vpn_server_manager.dart';
import 'vpn_connection_service.dart';
import 'vpn_ui_helper.dart';
import 'vpn_analytics_manager.dart';
import 'vpn_client_cleanup_manager.dart'; // ✅ NEW

/// Enhanced VPN controller với client cleanup management
class LocalController extends GetxController {
  // ===========================================
  // MANAGER INSTANCES
  // ===========================================

  late final VpnStateManager _stateManager;
  late final VpnServerManager _serverManager;
  late final VpnConnectionService _connectionService;
  late final VpnClientCleanupManager _cleanupManager; // ✅ NEW

  // ===========================================
  // DELEGATED PROPERTIES
  // ===========================================

  /// Current VPN connection state
  String get vpnState => _stateManager.vpnState.value;

  /// Connection status for UI feedback
  bool get isConnecting => _stateManager.isConnecting.value;
  set isConnecting(bool value) => _stateManager.isConnecting.value = value;

  bool get isDisconnecting => _stateManager.isDisconnecting.value;
  set isDisconnecting(bool value) =>
      _stateManager.isDisconnecting.value = value;

  int get countdownSeconds => _stateManager.countdownSeconds.value;
  set countdownSeconds(int value) =>
      _stateManager.countdownSeconds.value = value;

  /// Connection duration
  Duration get connectionDuration => _stateManager.connectionDuration.value;
  set connectionDuration(Duration value) =>
      _stateManager.connectionDuration.value = value;

  /// Currently selected VPN configuration
  Vpn get vpn => _serverManager.vpn.value;
  set vpn(Vpn value) => _serverManager.vpn.value = value;

  /// Currently selected server
  LocalVpnServer? get selectedServer => _serverManager.selectedServer.value;
  set selectedServer(LocalVpnServer? value) =>
      _serverManager.selectedServer.value = value;

  /// Server lists
  List<LocalVpnServer> get availableServers => _serverManager.availableServers;
  set availableServers(List<LocalVpnServer> value) =>
      _serverManager.availableServers.value = value;

  List<LocalVpnServer> get availableServersPro =>
      _serverManager.availableServersPro;
  set availableServersPro(List<LocalVpnServer> value) =>
      _serverManager.availableServersPro.value = value;

  List<LocalVpnServer> get availableServersFast =>
      _serverManager.availableServersFast;
  set availableServersFast(List<LocalVpnServer> value) =>
      _serverManager.availableServersFast.value = value;

  List<LocalVpnServer> get availableWireGuardServers =>
      _serverManager.availableWireGuardServers;
  set availableWireGuardServers(List<LocalVpnServer> value) =>
      _serverManager.availableWireGuardServers.value = value;

  List<LocalVpnServer> get availableStunnelWireGuardServers =>
      _serverManager.availableStunnelWireGuardServers;
  set availableStunnelWireGuardServers(List<LocalVpnServer> value) =>
      _serverManager.availableStunnelWireGuardServers.value = value;

  /// ✅ NEW: WireGuard API servers
  List<LocalVpnServer> get availableWireGuardApiServers =>
      _serverManager.availableWireGuardApiServers;
  set availableWireGuardApiServers(List<LocalVpnServer> value) =>
      _serverManager.availableWireGuardApiServers.value = value;

  List<Vpn> get availableApiServers => _serverManager.availableApiServers;
  set availableApiServers(List<Vpn> value) =>
      _serverManager.availableApiServers.value = value;

  /// Current server info getters
  String get currentCountry => _serverManager.currentCountry;
  String get currentCountryShort => _serverManager.currentCountryShort;
  String get currentFlagAsset => _serverManager.currentFlagAsset;
  bool get isUsingWireGuard => _serverManager.isUsingWireGuard;
  bool get isUsingStunnel => _serverManager.isUsingStunnel;

  /// ✅ NEW: WireGuard API specific getters
  bool get isUsingWireGuardApi => _serverManager.isUsingWireGuardApi;

  // ===========================================
  // LIFECYCLE METHODS
  // ===========================================

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  /// Initialize controller with all necessary setup
  void _initializeController() {
    // Initialize managers
    _stateManager = VpnStateManager();
    _serverManager = VpnServerManager();
    _connectionService = VpnConnectionService();
    _cleanupManager = VpnClientCleanupManager.instance; // ✅ NEW

    // Setup callbacks
    _setupCallbacks();

    // Initialize managers
    _stateManager.initialize();
    _serverManager.initialize();

    print('🎉 LocalController initialized with client cleanup support');
  }

  /// Setup callbacks between managers
  void _setupCallbacks() {
    // State manager callbacks
    _stateManager.onConnected = _handleConnectedState;
    _stateManager.onDisconnected = _handleDisconnectedState;
    _stateManager.onConnecting = _handleConnectingState;
    _stateManager.onError = _handleError;

    // Server manager callbacks
    _serverManager.onError = _handleError;

    // ✅ ENHANCED: Connection service callbacks với client tracking
    _connectionService.onError = _handleError;
    _connectionService.onRetryAttempt = _handleRetryAttempt;
    _connectionService.onClientCreated = _handleClientCreated; // NEW
    _connectionService.onClientCleanupNeeded = _handleClientCleanup; // NEW
  }

  /// ✅ NEW: Handle client created event
  void _handleClientCreated(
      String clientName, String protocol, String serverId) {
    print('👤 New client created: $clientName ($protocol)');
    _cleanupManager.registerClient(clientName, protocol, serverId);
  }

  /// ✅ NEW: Handle client cleanup needed event
  void _handleClientCleanup(String clientName) async {
    print('🗑️ Client cleanup requested: $clientName');
    try {
      await _cleanupManager.cleanupClient(clientName);
    } catch (e) {
      print('⚠️ Client cleanup error: $e');
      // Don't throw - cleanup errors shouldn't block main flow
    }
  }

  /// Clean up resources
  void _cleanup() {
    print('🧹 LocalController cleanup started...');

    // ✅ Emergency cleanup of any remaining clients
    _cleanupManager.cleanupAllClients().catchError((e) {
      print('⚠️ Error during emergency cleanup: $e');
    });

    _stateManager.dispose();
    print('✅ LocalController cleanup completed');
  }

  // ===========================================
  // VPN CONNECTION MANAGEMENT
  // ===========================================

  /// Main method to connect to VPN
  void connectToVpn() async {
    if (isConnecting || isDisconnecting) {
      MyDialogs.info(msg: 'VPN operation in progress. Please wait.');
      return;
    }

    final server = selectedServer;
    final apiVpn = vpn;
    final isApiVpnServer = _serverManager.isUsingApiServer;

    if (server == null && !isApiVpnServer) {
      MyDialogs.info(msg: 'Please select a VPN server!');
      return;
    }

    try {
      if (vpnState == VpnEngine.vpnConnected) {
        showDisconnectDialogWithAd();
        return;
      }

      _stateManager.startConnecting();
      _connectionService.resetRetryAttempts();

      await _connectionService.connectToVpn(
        server: server,
        apiVpn: apiVpn,
        isApiVpnServer: isApiVpnServer,
      );
    } catch (e) {
      _handleConnectionError('Connection failed', e);
    } finally {
      _stateManager.stopConnecting();
    }
  }

  /// Show disconnect dialog with advertisement
  void showDisconnectDialogWithAd() async {
    if (isDisconnecting) return;

    Get.dialog(
      WatchAdDialogDisconnect(
        onComplete: () async {
          await _disconnectVpn();
        },
      ),
    );
  }

  /// ✅ ENHANCED: Disconnect VPN với client cleanup
  Future<void> _disconnectVpn() async {
    print('🔥 LocalController._disconnectVpn() CALLED');

    final server = selectedServer;
    final apiVpn = vpn;
    final isApiVpnServer = _serverManager.isUsingApiServer;

    print('- server: ${server?.countryName} (${server?.protocol})');
    print('- isApiVpnServer: $isApiVpnServer');
    print('- vpnState: $vpnState');

    _stateManager.startDisconnecting();

    try {
      // Calculate and store final connection duration BEFORE disconnecting
      if (vpnState == VpnEngine.vpnConnected) {
        final duration = _stateManager.displayDuration;
        final durationInSeconds = duration.inSeconds;
        VpnAnalyticsManager.logVpnDisconnect(currentCountry, durationInSeconds);
        print(
            '💾 Logged disconnect with duration: ${_stateManager.formatDuration(duration)}');
      }

      print('🔄 Calling _connectionService.disconnectVpn()...');

      // 🔥 Main disconnect call với client cleanup
      await _connectionService.disconnectVpn(
        server: server,
        apiVpn: apiVpn,
        isApiVpnServer: isApiVpnServer,
      );

      print('✅ _connectionService.disconnectVpn() completed');
    } catch (e) {
      print('❌ LocalController._disconnectVpn() ERROR: $e');
      _handleError('Failed to disconnect VPN', e);
      _stateManager.stopDisconnecting();
      rethrow;
    }

    print('🎉 LocalController._disconnectVpn() COMPLETED');
  }

  // ===========================================
  // SERVER MANAGEMENT
  // ===========================================

  /// Change VPN server from LocalVpnServer
  Future<void> setVpnFromLocalServer(LocalVpnServer server) async {
    try {
      // Nếu đang connected, cảnh báo người dùng
      if (vpnState == VpnEngine.vpnConnected) {
        MyDialogs.info(
          msg: 'Please disconnect VPN first before changing server!',
        );
        await Future.delayed(Duration(seconds: 3));
        return;
      }

      await _serverManager.setVpnFromLocalServer(server);

      // Log server selection with protocol info
      VpnAnalyticsManager.logServerSelection(
          '${server.countryName} (${server.protocol})', server.countryCode);

      // ✅ Log specific info for WireGuard API
      if (server.protocol == 'wireguard-api') {
        print('🌐 Selected WireGuard API server: ${server.countryName}');
      }

      update();
    } catch (e) {
      _handleError('Failed to set VPN server', e);
    }
  }

  /// ✅ NEW: Change VPN server from API Vpn
  Future<void> setVpnFromApiServer(Vpn server) async {
    try {
      // Nếu đang connected, cảnh báo người dùng
      if (vpnState == VpnEngine.vpnConnected) {
        MyDialogs.info(
          msg: 'Please disconnect VPN first before changing server!',
        );
        await Future.delayed(Duration(seconds: 3));
        return;
      }

      await _serverManager.setVpnFromApiServer(server);

      // Log server selection
      VpnAnalyticsManager.logServerSelection(
          server.CountryLong, server.CountryShort);

      update();
    } catch (e) {
      _handleError('Failed to set API VPN server', e);
    }
  }

  /// ✅ NEW: Get server manager for external access (if needed)
  VpnServerManager get serverManager => _serverManager;

  // ===========================================
  // ✅ NEW: CLIENT CLEANUP METHODS
  // ===========================================

  /// Get current tracked clients info
  Map<String, ClientInfo> get trackedClients => _cleanupManager.activeClients;

  /// Force cleanup all clients (emergency)
  Future<void> forceCleanupAllClients() async {
    print('🚨 Force cleanup all clients requested');
    try {
      await _cleanupManager.cleanupAllClients();
      print('✅ Force cleanup completed');
    } catch (e) {
      print('❌ Force cleanup error: $e');
      _handleError('Force cleanup failed', e);
    }
  }

  /// Cleanup old clients
  Future<void> cleanupOldClients() async {
    print('🧹 Cleanup old clients requested');
    try {
      await _cleanupManager.cleanupOldClients();
      print('✅ Old clients cleanup completed');
    } catch (e) {
      print('❌ Old clients cleanup error: $e');
      _handleError('Old clients cleanup failed', e);
    }
  }

  /// Check if client is being tracked
  bool isClientTracked(String clientName) {
    return _cleanupManager.isClientTracked(clientName);
  }

  // ===========================================
  // UI HELPERS
  // ===========================================

  /// Get button content based on VPN state
  Widget get getButtonContent {
    return VpnUIHelper.getButtonContent(vpnState, countdownSeconds);
  }

  /// Get button gradient based on VPN state
  LinearGradient getButtonGradient() {
    return VpnUIHelper.getButtonGradient();
  }

  // ===========================================
  // STATE HANDLERS
  // ===========================================

  /// Handle connected state
  void _handleConnectedState() {
    // Log analytics with protocol info
    final protocolInfo = isUsingWireGuardApi
        ? 'WireGuard API'
        : isUsingWireGuard
            ? 'WireGuard'
            : 'OpenVPN';

    print('✅ Connected via $protocolInfo: $currentCountry');
    VpnAnalyticsManager.logVpnConnect(currentCountry, currentCountryShort);

    // Show interstitial ad and navigate to connected screen
    Future.delayed(const Duration(milliseconds: 1000), () {
      final currentServerData = _serverManager.currentServer;
      if (currentServerData != null) {
        print('*****ads inter after connect*****');
        AdHelper.showInterstitialAd(onComplete: () async {
          await Get.to(() => ConnectedScreen(server: currentServerData));
        });
      }
    });

    update();
  }

  /// ✅ ENHANCED: Handle disconnected state với client cleanup check
  void _handleDisconnectedState() {
    // Check if this is a timeout disconnect
    if (_stateManager.isTimeoutDisconnect) {
      print('⏰ Timeout disconnect detected - skipping disconnected screen');
      return;
    }

    // ✅ Check for any remaining tracked clients and cleanup
    final trackedCount = _cleanupManager.activeClients.length;
    if (trackedCount > 0) {
      print(
          '🗑️ Found $trackedCount tracked clients after disconnect - cleaning up...');
      _cleanupManager.cleanupAllClients().catchError((e) {
        print('⚠️ Post-disconnect cleanup error: $e');
      });
    }

    // Get formatted connection duration
    final timeToShow = _stateManager.displayDuration;
    final formattedTime = _stateManager.formatDuration(timeToShow);

    print(
        '⏱️ Connection duration to show: ${_stateManager.formatDuration(timeToShow)}');

    // Show disconnection screen
    final currentServerData = _serverManager.currentServer;
    if (currentServerData != null) {
      _showDisconnectionAdAndNavigate(formattedTime, currentServerData);
    }

    // Auto-reconnect if not user initiated and can retry
    if (!_stateManager.isUserInitiatedDisconnect &&
        _connectionService.canRetryConnection()) {
      _connectionService.incrementRetryAttempts();
      print(
          '🔁 Attempting to reconnect VPN... (${_connectionService.retryAttempts}/${_connectionService.maxRetryAttempts})');
      Future.delayed(const Duration(seconds: 2), () {
        connectToVpn();
      });
    }

    update();
  }

  /// Handle connecting state
  void _handleConnectingState() {
    final protocolInfo = isUsingWireGuardApi
        ? 'WireGuard API'
        : isUsingWireGuard
            ? 'WireGuard'
            : 'OpenVPN';
    print('🔄 Connecting via $protocolInfo...');
    update();
  }

  /// Show disconnection ad and navigate to disconnected screen
  void _showDisconnectionAdAndNavigate(
      String formattedTime, LocalVpnServer server) {
    Future.delayed(const Duration(milliseconds: 500), () {
      print('*****show disconnected screen with time: $formattedTime *****');

      Future.delayed(const Duration(milliseconds: 500), () {
        print('🔥 Navigating to disconnected screen...');

        Get.to(() => DisconnectedScreen(
              country: currentCountry,
              connectionTime: formattedTime,
              uploadSpeed: getRandomUploadSpeed(),
              downloadSpeed: getRandomDownloadSpeed(),
              flagUrl: currentFlagAsset,
            ));
      });
    });
  }

  // ===========================================
  // RATING AND ANALYTICS
  // ===========================================

  /// Increment connection attempts and check for rating display
  void incrementConnectionAttempts(BuildContext context) {
    VpnAnalyticsManager.incrementConnectionAttempts(context);
  }

  // ===========================================
  // ERROR HANDLERS
  // ===========================================

  /// ✅ ENHANCED: Handle general errors với cleanup check
  void _handleError(String message, dynamic error) {
    print('LocalController Error: $message - $error');
    VpnAnalyticsManager.logConnectionError(message, _getServerType());

    // ✅ Check for orphaned clients on error
    final trackedCount = _cleanupManager.activeClients.length;
    if (trackedCount > 0) {
      print(
          '🗑️ Found $trackedCount tracked clients after error - cleaning up...');
      _cleanupManager.cleanupAllClients().catchError((e) {
        print('⚠️ Post-error cleanup error: $e');
      });
    }

    // Handle timeout specifically
    if (error == 'timeout') {
      _handleTimeoutError();
    }
  }

  /// Handle connection-specific errors with retry logic
  void _handleConnectionError(String message, dynamic error) {
    _handleError(message, error);

    if (_connectionService.canRetryConnection()) {
      MyDialogs.info(
          msg:
              '$message. Retrying... (${_connectionService.retryAttempts + 1}/${_connectionService.maxRetryAttempts})');
    } else {
      MyDialogs.info(msg: '$message. Please try again later.');
    }
  }

  /// Handle retry attempts
  void _handleRetryAttempt() {
    final serverType = _getServerType();
    VpnAnalyticsManager.logConnectionRetry(
        _connectionService.retryAttempts, serverType);
  }

  /// Handle timeout error by stopping VPN
  void _handleTimeoutError() async {
    print('⏰ Handling connection timeout - stopping VPN...');

    final server = selectedServer;
    final apiVpn = vpn;
    final isApiVpnServer = _serverManager.isUsingApiServer;

    try {
      await _connectionService.handleConnectionTimeout(
        server: server,
        apiVpn: apiVpn,
        isApiVpnServer: isApiVpnServer,
      );

      VpnAnalyticsManager.logConnectionTimeout(_getServerType());
      print('✅ VPN stopped due to timeout');
    } catch (e) {
      print('❌ Error stopping VPN on timeout: $e');
    }
  }

  /// ✅ UPDATED: Get current server type for logging
  String _getServerType() {
    final server = selectedServer;
    if (server != null) {
      if (server.protocol == 'wireguard-api') {
        return 'wireguard-api';
      }
      return server.protocol;
    } else if (_serverManager.isUsingApiServer) {
      return 'api-openvpn';
    } else {
      return 'openvpn';
    }
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  /// Format duration as HH:MM:SS
  String formatDuration(Duration duration) {
    return _stateManager.formatDuration(duration);
  }

  /// Load specific server types (delegates to server manager)
  void loadAvailableServers() => _serverManager.loadAvailableServers();
  void loadAvailableServersPro() => _serverManager.loadAvailableServersPro();
  void loadAvailableServersFast() => _serverManager.loadAvailableServersFast();
  void loadAvailableWireGuardServers() =>
      _serverManager.loadAvailableWireGuardServers();
  void loadAvailableStunnelWireGuardServers() =>
      _serverManager.loadAvailableStunnelWireGuardServers();

  /// ✅ NEW: Load WireGuard API servers
  void loadAvailableWireGuardApiServers() =>
      _serverManager.loadAvailableWireGuardApiServers();

  // ===========================================
  // ✅ NEW HELPER METHODS FOR UI
  // ===========================================

  /// Get all WireGuard servers (both assets and API)
  List<LocalVpnServer> get allWireGuardServers {
    List<LocalVpnServer> allServers = [];
    allServers.addAll(availableWireGuardServers);
    allServers.addAll(availableWireGuardApiServers);
    return allServers;
  }

  /// Check if current server is from API
  bool get isCurrentServerFromApi {
    return selectedServer?.protocol == 'wireguard-api' ||
        _serverManager.isUsingApiServer;
  }

  /// Get server connection info for UI
  String get serverConnectionInfo {
    if (isUsingWireGuardApi) {
      return 'WireGuard API • ${currentCountry}';
    } else if (isUsingWireGuard) {
      return 'WireGuard • ${currentCountry}';
    } else if (isUsingStunnel) {
      return 'Stunnel+WireGuard • ${currentCountry}';
    } else {
      return 'OpenVPN • ${currentCountry}';
    }
  }

  /// ✅ NEW: Get client cleanup status for debugging
  Map<String, dynamic> get clientCleanupStatus {
    return {
      'trackedClients': _cleanupManager.activeClients.length,
      'clients': _cleanupManager.activeClients.keys.toList(),
      'isCleanupActive': _cleanupManager.activeClients.isNotEmpty,
    };
  }
}
