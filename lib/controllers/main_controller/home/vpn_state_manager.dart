import 'dart:async';
import 'package:get/get.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/services/stunnel_engine.dart';

/// Quản lý trạng thái VPN và các luồng dữ liệu
class VpnStateManager {
  // ===========================================
  // OBSERVABLE PROPERTIES
  // ===========================================

  /// Current VPN connection state
  final vpnState = VpnEngine.vpnDisconnected.obs;

  /// Connection status for UI feedback
  final isConnecting = false.obs;
  final isDisconnecting = false.obs;
  final countdownSeconds = 60.obs;

  /// Connection duration timer
  final connectionDuration = const Duration().obs;

  // ===========================================
  // PRIVATE PROPERTIES
  // ===========================================

  StreamSubscription<String>? _vpnStageSub;
  StreamSubscription<String>? _stunnelStageSub;
  DateTime? _connectionStartTime;
  Timer? _connectionTimer;
  Timer? _connectionTimeoutTimer;

  bool _userInitiatedDisconnect = false;
  bool _isTimeoutDisconnect = false;

  // Store the final connection duration when disconnecting
  Duration? _finalConnectionDuration;

  static const int _connectionTimeoutSeconds = 60;

  // ===========================================
  // CALLBACKS
  // ===========================================

  Function()? onConnected;
  Function()? onDisconnected;
  Function()? onConnecting;
  Function(String message, dynamic error)? onError;

  // ===========================================
  // PUBLIC METHODS
  // ===========================================

  /// Initialize state manager
  void initialize() {
    _listenVpnStage();
    _listenStunnelStage();
    _startConnectionTimer();
  }

  /// Clean up resources
  void dispose() {
    _vpnStageSub?.cancel();
    _stunnelStageSub?.cancel();
    _connectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
  }

  /// Start connection state tracking
  void startConnecting() {
    isConnecting.value = true;
    _startConnectionTimeoutTimer();
  }

  /// Stop connection state tracking
  void stopConnecting() {
    isConnecting.value = false;
    _connectionTimeoutTimer?.cancel();
    countdownSeconds.value = _connectionTimeoutSeconds;
  }

  /// Start disconnection state tracking
  void startDisconnecting() {
    isDisconnecting.value = true;
    _userInitiatedDisconnect = true;
  }

  /// Stop disconnection state tracking
  void stopDisconnecting() {
    isDisconnecting.value = false;
  }

  /// Set timeout disconnect flag
  void setTimeoutDisconnect(bool value) {
    _isTimeoutDisconnect = value;
  }

  /// Get current connection duration for display
  Duration get displayDuration =>
      _finalConnectionDuration ?? connectionDuration.value;

  /// Check if user initiated disconnect
  bool get isUserInitiatedDisconnect => _userInitiatedDisconnect;

  /// Check if timeout disconnect
  bool get isTimeoutDisconnect => _isTimeoutDisconnect;

  /// Format duration as HH:MM:SS
  String formatDuration(Duration duration) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(duration.inHours);
    final minutes = twoDigit(duration.inMinutes.remainder(60));
    final seconds = twoDigit(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // ===========================================
  // PRIVATE METHODS
  // ===========================================

  /// Listen to VPN stage changes from native
  void _listenVpnStage() {
    _vpnStageSub?.cancel();
    _vpnStageSub = VpnEngine.vpnStageSnapshot().listen(
      _handleStageChange,
      onError: (error) => onError?.call('VPN stage listener error', error),
    );
  }

  /// Listen to Stunnel stage changes
  void _listenStunnelStage() {
    _stunnelStageSub?.cancel();
    _stunnelStageSub = StunnelEngine.stunnelStatusStream().listen(
      _handleStunnelStageChange,
      onError: (error) => onError?.call('Stunnel stage listener error', error),
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
        // Treat other transitional stages as connecting to ensure timeout handling
        if (VpnEngine.isStageConnecting(stageLower)) {
          if (!isConnecting.value) {
            startConnecting();
          }
        }
    }
  }

  /// Handle Stunnel stage changes
  void _handleStunnelStageChange(String stage) {
    final stageLower = stage.toLowerCase();
    print('🔄 Stunnel stage changed: $stageLower');

    if (stageLower == StunnelEngine.stunnelConnected) {
      print('✅ Stunnel tunnel is ready');
    }
  }

  /// Handle connected state
  void _handleConnectedState() {
    vpnState.value = VpnEngine.vpnConnected;
    _connectionStartTime = DateTime.now();
    _userInitiatedDisconnect = false;
    isConnecting.value = false;
    isDisconnecting.value = false;

    // Cancel connection timeout timer since we're now connected
    _connectionTimeoutTimer?.cancel();
    countdownSeconds.value = _connectionTimeoutSeconds;

    // Clear any previous final duration when connecting
    _finalConnectionDuration = null;

    print('✅ VPN Connected at: $_connectionStartTime');
    onConnected?.call();
  }

  /// Handle disconnected state
  void _handleDisconnectedState() {
    print('🔴 VPN Disconnected - State changed to disconnected');

    vpnState.value = VpnEngine.vpnDisconnected;
    isConnecting.value = false;

    // Cancel connection timeout timer
    _connectionTimeoutTimer?.cancel();
    countdownSeconds.value = _connectionTimeoutSeconds;

    // Calculate and store final connection duration BEFORE processing disconnect
    if (_connectionStartTime != null) {
      _finalConnectionDuration =
          DateTime.now().difference(_connectionStartTime!);
      print(
          '💾 Stored final connection duration: ${formatDuration(_finalConnectionDuration!)}');
    }

    // Reset connection tracking
    _connectionStartTime = null;
    connectionDuration.value = Duration.zero;

    // Check if this is a timeout disconnect
    if (_isTimeoutDisconnect) {
      print('⏰ Timeout disconnect detected - skipping disconnected screen');
      _isTimeoutDisconnect = false;
      isDisconnecting.value = false;
      return;
    }

    onDisconnected?.call();
    isDisconnecting.value = false;
  }

  /// Handle connecting state
  void _handleConnectingState() {
    vpnState.value = VpnEngine.vpnConnecting;
    isDisconnecting.value = false;
    onConnecting?.call();
  }

  /// Start connection duration timer
  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (vpnState.value == VpnEngine.vpnConnected &&
          _connectionStartTime != null) {
        connectionDuration.value =
            DateTime.now().difference(_connectionStartTime!);
      } else if (vpnState.value == VpnEngine.vpnDisconnected) {
        connectionDuration.value = Duration.zero;
      }
    });
  }

  /// Start connection timeout timer
  void _startConnectionTimeoutTimer() {
    _connectionTimeoutTimer?.cancel();
    countdownSeconds.value = _connectionTimeoutSeconds;
    _connectionTimeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isConnecting.value && vpnState.value != VpnEngine.vpnConnected) {
        if (countdownSeconds.value > 0) {
          countdownSeconds.value--;
        } else {
          timer.cancel();
          print(
              '⏰ Connection timeout after $_connectionTimeoutSeconds seconds');
          _handleConnectionTimeout();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Handle connection timeout
  void _handleConnectionTimeout() {
    if (isConnecting.value && vpnState.value != VpnEngine.vpnConnected) {
      print('🔄 Connection timeout detected');
      isConnecting.value = false;
      _isTimeoutDisconnect = true;

      // Reset connection tracking
      _connectionStartTime = null;
      connectionDuration.value = Duration.zero;
      _finalConnectionDuration = null;
      countdownSeconds.value = _connectionTimeoutSeconds;

      // Notify timeout - this should trigger VPN stop in the controller
      onError?.call('Connection timeout', 'timeout');
    }
  }
}
