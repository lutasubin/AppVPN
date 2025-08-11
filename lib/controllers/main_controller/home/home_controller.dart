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

/// Enhanced VPN controller được tái cấu trúc với các manager riêng biệt
class LocalController extends GetxController {
  // ===========================================
  // MANAGER INSTANCES
  // ===========================================

  late final VpnStateManager _stateManager;
  late final VpnServerManager _serverManager;
  late final VpnConnectionService _connectionService;

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

  List<Vpn> get availableApiServers => _serverManager.availableApiServers;
  set availableApiServers(List<Vpn> value) =>
      _serverManager.availableApiServers.value = value;

  /// Current server info getters
  String get currentCountry => _serverManager.currentCountry;
  String get currentCountryShort => _serverManager.currentCountryShort;
  String get currentFlagAsset => _serverManager.currentFlagAsset;
  bool get isUsingWireGuard => _serverManager.isUsingWireGuard;
  bool get isUsingStunnel => _serverManager.isUsingStunnel;

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

    // Setup callbacks
    _setupCallbacks();

    // Initialize managers
    _stateManager.initialize();
    _serverManager.initialize();
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

    // Connection service callbacks
    _connectionService.onError = _handleError;
    _connectionService.onRetryAttempt = _handleRetryAttempt;
  }

  /// Clean up resources
  void _cleanup() {
    _stateManager.dispose();
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

  /// Disconnect VPN based on protocol
  Future<void> _disconnectVpn() async {
    final server = selectedServer;
    final apiVpn = vpn;
    final isApiVpnServer = _serverManager.isUsingApiServer;

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

      await _connectionService.disconnectVpn(
        server: server,
        apiVpn: apiVpn,
        isApiVpnServer: isApiVpnServer,
      );
    } catch (e) {
      _handleError('Failed to disconnect VPN', e);
      _stateManager.stopDisconnecting();
      rethrow;
    }
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

      // Log server selection
      VpnAnalyticsManager.logServerSelection(
          server.countryName, server.countryCode);

      update();
    } catch (e) {
      _handleError('Failed to set VPN server', e);
    }
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
    // Log analytics
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

  /// Handle disconnected state
  void _handleDisconnectedState() {
    // Check if this is a timeout disconnect
    if (_stateManager.isTimeoutDisconnect) {
      print('⏰ Timeout disconnect detected - skipping disconnected screen');
      return;
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

  /// Handle general errors
  void _handleError(String message, dynamic error) {
    print('LocalController Error: $message - $error');
    VpnAnalyticsManager.logConnectionError(message, _getServerType());

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

  /// Get current server type for logging
  String _getServerType() {
    final server = selectedServer;
    if (server != null) {
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
  // void loadAvailableServersFast() => _serverManager.loadAvailableServersFast();
  // void loadAvailableWireGuardServers() => _serverManager.loadAvailableWireGuardServers();
  // void loadAvailableStunnelWireGuardServers() => _serverManager.loadAvailableStunnelWireGuardServers();
}
