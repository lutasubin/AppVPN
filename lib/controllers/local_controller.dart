import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/local_vpn.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/watch_video_disconnect.dart';
import '../screens/menu/rate/rate_screen.dart';

/// Enhanced VPN controller with better error handling and organization
class LocalController extends GetxController {
  // ===========================================
  // OBSERVABLE PROPERTIES
  // ===========================================

  /// Currently selected VPN configuration
  final Rx<Vpn> vpn = Pref.vpn.obs;

  /// Current VPN connection state
  final vpnState = VpnEngine.vpnDisconnected.obs;

  /// Connection duration timer
  final connectionDuration = Duration().obs;

  /// Currently selected server (OpenVPN or WireGuard)
  final Rx<LocalVpnServer?> selectedServer = Rx<LocalVpnServer?>(null);

  /// Connection status for UI feedback
  final isConnecting = false.obs;
  final isDisconnecting = false.obs;

  // Server lists
  final RxList<LocalVpnServer> availableServers = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableServersPro = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableServersFast = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableWireGuardServers =
      <LocalVpnServer>[].obs;

  // ===========================================
  // PRIVATE PROPERTIES
  // ===========================================

  StreamSubscription<String>? _vpnStageSub;
  DateTime? _connectionStartTime;
  Timer? _connectionTimer;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3;

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
    _listenVpnStage();
    _loadAllServers();
    _startConnectionTimer();
  }

  /// Clean up resources
  void _cleanup() {
    _vpnStageSub?.cancel();
    _connectionTimer?.cancel();
  }

  // ===========================================
  // SERVER MANAGEMENT
  // ===========================================

  /// Load all available servers
  void _loadAllServers() {
    try {
      loadAvailableServers();
      loadAvailableServersPro();
      loadAvailableServersFast();
      loadAvailableWireGuardServers();
    } catch (e) {
      _handleError('Failed to load servers', e);
    }
  }

  /// Load high-speed VPN servers
  void loadAvailableServers() {
    try {
      availableServers.value = highVpn;
      _setDefaultServerIfNeeded(availableServers);
    } catch (e) {
      _handleError('Failed to load high-speed servers', e);
    }
  }

  /// Load pro VPN servers
  void loadAvailableServersPro() {
    try {
      availableServersPro.value = proVPN;
      _setDefaultServerIfNeeded(availableServersPro);
    } catch (e) {
      _handleError('Failed to load pro servers', e);
    }
  }

  /// Load fast VPN servers
  void loadAvailableServersFast() {
    try {
      availableServersFast.value = fastVpn;
      _setDefaultServerIfNeeded(availableServersFast);
    } catch (e) {
      _handleError('Failed to load fast servers', e);
    }
  }

  /// Load WireGuard servers
  void loadAvailableWireGuardServers() {
    try {
      availableWireGuardServers.value = wireguardVpn;
    } catch (e) {
      _handleError('Failed to load WireGuard servers', e);
    }
  }

  /// Set default server if current VPN config is empty
  void _setDefaultServerIfNeeded(List<LocalVpnServer> servers) {
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty && servers.isNotEmpty) {
      setVpnFromLocalServer(servers[0]);
    }
  }

  // ===========================================
  // VPN CONNECTION MANAGEMENT
  // ===========================================

  /// Main method to connect to VPN
  void connectToVpn() async {
    if (isConnecting.value || isDisconnecting.value) {
      MyDialogs.info(msg: 'VPN operation in progress. Please wait.');
      return;
    }

    final server = selectedServer.value;
    if (server == null) {
      MyDialogs.info(msg: 'Please select a VPN server!');
      return;
    }

    try {
      if (vpnState.value == VpnEngine.vpnConnected) {
        showDisconnectDialogWithAd();
        return;
      }

      isConnecting.value = true;
      _retryAttempts = 0;

      if (server.protocol == 'wireguard') {
        await _connectWireGuard(server);
      } else {
        await _connectOpenVPN();
      }
    } catch (e) {
      _handleConnectionError('Connection failed', e);
    } finally {
      isConnecting.value = false;
    }
  }

  /// Connect to WireGuard VPN
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

  /// Connect to OpenVPN
  Future<void> _connectOpenVPN() async {
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      throw Exception('Select a Location by clicking \'Change Location\'');
    }

    try {
      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
        country: vpn.value.CountryLong,
        username: '',
        password: '',
        config: config,
      );

      await VpnEngine.startVpn(vpnConfig);
    } catch (e) {
      throw Exception('OpenVPN connection failed: ${e.toString()}');
    }
  }

  /// Show disconnect dialog with advertisement
  void showDisconnectDialogWithAd() async {
    if (isDisconnecting.value) return;

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
    final server = selectedServer.value;

    try {
      if (server != null && server.protocol == 'wireguard') {
        await VpnEngine.stopWireGuard();
      } else {
        await VpnEngine.stopVpn();
      }

      // Log disconnect analytics
      if (_connectionStartTime != null &&
          vpnState.value == VpnEngine.vpnConnected) {
        final durationInSeconds =
            DateTime.now().difference(_connectionStartTime!).inSeconds;
        AnalyticsHelper.logVpnDisconnect(currentCountry, durationInSeconds);
      }
    } catch (e) {
      _handleError('Failed to disconnect VPN', e);
      rethrow;
    }
  }

  // ===========================================
  // VPN STATE MANAGEMENT
  // ===========================================

  /// Listen to VPN stage changes from native
  void _listenVpnStage() {
    _vpnStageSub?.cancel();
    _vpnStageSub = VpnEngine.vpnStageSnapshot().listen(
      _handleStageChange,
      onError: (error) => _handleError('VPN stage listener error', error),
    );
  }

  /// Handle VPN stage changes
  void _handleStageChange(String stage) {
    final stageLower = stage.toLowerCase();

    switch (stageLower) {
      case VpnEngine.vpnConnected:
        _handleConnectedState();
        break;
      case VpnEngine.vpnDisconnected:
        _handleDisconnectedState();
        break;
      case VpnEngine.vpnConnecting:
        _handleConnectingState();
        break;
      default:
        vpnState.value = stageLower;
    }

    update();
  }

  /// Handle connected state
  void _handleConnectedState() {
    vpnState.value = VpnEngine.vpnConnected;
    _connectionStartTime = DateTime.now();
    isConnecting.value = false;
    _retryAttempts = 0;

    // Log analytics
    AnalyticsHelper.logVpnConnect(currentCountry, currentCountryShort);
  }

  /// Handle disconnected state
  void _handleDisconnectedState() {
    // Log disconnect if was previously connected
    if (_connectionStartTime != null &&
        vpnState.value == VpnEngine.vpnConnected) {
      final durationInSeconds =
          DateTime.now().difference(_connectionStartTime!).inSeconds;
      AnalyticsHelper.logVpnDisconnect(currentCountry, durationInSeconds);
    }

    vpnState.value = VpnEngine.vpnDisconnected;
    _connectionStartTime = null;
    isConnecting.value = false;
    isDisconnecting.value = false;
  }

  /// Handle connecting state
  void _handleConnectingState() {
    vpnState.value = VpnEngine.vpnConnecting;
    isDisconnecting.value = false;
  }

  // ===========================================
  // SERVER SELECTION
  // ===========================================

  /// Change VPN server from LocalVpnServer
  /// Change VPN server from LocalVpnServer
  Future<void> setVpnFromLocalServer(LocalVpnServer server) async {
    try {
      // ✅ QUAN TRỌNG: Set selectedServer TRƯỚC TIÊN
      selectedServer.value = server;

      // Disconnect if currently connected
      if (vpnState.value == VpnEngine.vpnConnected) {
        await VpnEngine.stopVpn();
      }

      // Xử lý cả OpenVPN và WireGuard
      if (server.protocol == 'openvpn' || server.protocol == 'wireguard') {
        final newVpn = await server.toVpn();
        vpn.value = newVpn;
        Pref.vpn = newVpn;
      }

      // Log server selection
      AnalyticsHelper.logServerSelection(
          server.countryName, server.countryCode);

      // Force UI update
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
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
      case VpnEngine.vpnPrepare:
        return _buildButtonText('Connect'.tr, 20);

      case VpnEngine.vpnConnected:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildButtonText('Connected'.tr, 18),
          ],
        );

      case VpnEngine.vpnConnecting:
      case VpnEngine.vpnWaitConnection:
      case VpnEngine.vpnAuthenticating:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildButtonText('Connecting....'.tr, 18),
          ],
        );

      default:
        return _buildButtonText('Waiting....'.tr, 18);
    }
  }

  /// Build button text widget
  Widget _buildButtonText(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Get button gradient based on VPN state
  LinearGradient getButtonGradient() {
    const connectedColors = [Color(0xFF15EDB3), Color(0xFF2484F1)];

    return LinearGradient(
      colors: connectedColors,
      stops: List.generate(
          connectedColors.length, (i) => i / (connectedColors.length - 1)),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // ===========================================
  // GETTERS FOR CURRENT SERVER INFO
  // ===========================================

  /// Get current country name (prioritize WireGuard)
  String get currentCountry {
    final server = selectedServer.value;
    if (server != null && server.protocol == 'wireguard') {
      return server.countryName;
    }
    return vpn.value.CountryLong;
  }

  /// Get current country code (prioritize WireGuard)
  String get currentCountryShort {
    final server = selectedServer.value;
    if (server != null && server.protocol == 'wireguard') {
      return server.countryCode;
    }
    return vpn.value.CountryShort;
  }

  /// Get current flag asset path (prioritize WireGuard)
  String get currentFlagAsset {
    final code = currentCountryShort;
    if (code.isEmpty) return '';
    return 'assets/flags/${code.toLowerCase()}.png';
  }

  /// Check if currently using WireGuard protocol
  bool get isUsingWireGuard {
    final server = selectedServer.value;
    return server != null && server.protocol == 'wireguard';
  }

  // ===========================================
  // RATING AND ANALYTICS
  // ===========================================

  /// Increment connection attempts and check for rating display
  void incrementConnectionAttempts(BuildContext context) {
    if (!Pref.hasShownRating) {
      int attempts = Pref.connectionAttempts + 1;
      Pref.connectionAttempts = attempts;

      if (attempts >= 3) {
        Future.delayed(const Duration(seconds: 1), () {
          showRatingScreen(context);
        });
      }
    }
  }

  /// Show rating screen
  void showRatingScreen(BuildContext context) {
    Pref.hasShownRating = true;
    Pref.resetConnectionAttempts();
    showRatingBottomSheet2(context);
  }

  /// Show rating bottom sheet
  void showRatingBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => const RatingBottomSheet(),
    );
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  /// Start connection duration timer
  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (vpnState.value == VpnEngine.vpnConnected &&
          _connectionStartTime != null) {
        connectionDuration.value =
            DateTime.now().difference(_connectionStartTime!);
      } else {
        connectionDuration.value = Duration.zero;
      }
    });
  }

  /// Format duration as HH:MM:SS
  String formatDuration(Duration duration) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(duration.inHours);
    final minutes = twoDigit(duration.inMinutes.remainder(60));
    final seconds = twoDigit(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Handle errors with consistent logging and user feedback
  void _handleError(String message, dynamic error) {
    print('LocalController Error: $message - $error');
    // Could also log to analytics or crash reporting service
  }

  /// Handle connection-specific errors with retry logic
  void _handleConnectionError(String message, dynamic error) {
    _handleError(message, error);

    if (_retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;
      MyDialogs.info(
          msg: '$message. Retrying... (${_retryAttempts}/$_maxRetryAttempts)');
    } else {
      MyDialogs.info(msg: '$message. Please try again later.');
      isConnecting.value = false;
    }
  }
}
