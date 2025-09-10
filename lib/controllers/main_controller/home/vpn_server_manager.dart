import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/vpn_gate.dart';
import 'package:vpn_basic_project/apis/local_vpn.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';

/// Quản lý danh sách server và việc chọn server
class VpnServerManager {
  // ===========================================
  // OBSERVABLE PROPERTIES
  // ===========================================

  /// Currently selected VPN configuration
  final Rx<Vpn> vpn = Pref.vpn.obs;

  /// Currently selected server (OpenVPN or WireGuard)
  final Rx<LocalVpnServer?> selectedServer = Rx<LocalVpnServer?>(null);

  /// ✅ NEW: Flag to track if using API server (either OpenVPN or WireGuard API)
  final RxBool _isUsingApiVpn = false.obs;

  /// ✅ NEW: Flag to track server source type
  final RxString _serverSourceType =
      'none'.obs; // 'local', 'api-openvpn', 'api-wireguard'

  // Server lists
  final RxList<LocalVpnServer> availableServers = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableServersPro = <LocalVpnServer>[].obs;
  
  final RxList<LocalVpnServer> availableStunnelWireGuardServers =
      <LocalVpnServer>[].obs;

  // ✅ NEW: WireGuard API servers
  final RxList<LocalVpnServer> availableWireGuardApiServers =
      <LocalVpnServer>[].obs;

  // API Server list
  final RxList<Vpn> availableApiServers = <Vpn>[].obs;

  // ===========================================
  // CALLBACKS
  // ===========================================

  Function(String, dynamic)? onError;

  // ===========================================
  // PUBLIC METHODS
  // ===========================================

  /// Initialize server manager
  void initialize() {
    _loadAllServers();
    _loadApiServers();
  }

  /// Load all available servers
  void _loadAllServers() {
    try {
      loadAvailableServers();
      loadAvailableServersPro();
      loadAvailableStunnelWireGuardServers();
      loadAvailableWireGuardApiServers(); // ✅ NEW: Load API servers
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


  /// ✅ NEW: Load WireGuard API servers
  void loadAvailableWireGuardApiServers() {
    try {
      availableWireGuardApiServers.value = wireguardApiVpn;
      print('✅ Loaded ${wireguardApiVpn.length} WireGuard API servers');
      for (var server in wireguardApiVpn) {
        print('  - ${server.countryName} (${server.protocol})');
      }
    } catch (e) {
      print('❌ Error loading WireGuard API servers: $e');
      _handleError('Failed to load WireGuard API servers', e);
    }
  }

  /// Load Stunnel + WireGuard servers
  void loadAvailableStunnelWireGuardServers() {
    try {
      availableStunnelWireGuardServers.value = stunnelWireguardVpn;
      print('✅ Loaded ${stunnelWireguardVpn.length} Stunnel-WireGuard servers');
      for (var server in stunnelWireguardVpn) {
        print('  - ${server.countryName} (${server.protocol})');
      }
    } catch (e) {
      print('❌ Error loading Stunnel-WireGuard servers: $e');
      _handleError('Failed to load Stunnel-WireGuard servers', e);
    }
  }

  /// Load API servers
  void _loadApiServers() async {
    try {
      final servers = await APIs.getVPNServers();
      availableApiServers.value = servers;
      print('✅ Loaded ${servers.length} API servers');
    } catch (e) {
      print('❌ Error loading API servers: $e');
      _handleError('Failed to load API servers', e);
    }
  }

  /// Change VPN server from LocalVpnServer
  Future<void> setVpnFromLocalServer(LocalVpnServer server) async {
    try {
      print(
          '🔧 Setting local server: ${server.countryName} (${server.protocol})');

      // Set server mới
      selectedServer.value = server;

      // ✅ UPDATED: Handle different protocols including wireguard-api
      if (server.protocol == 'wireguard' ||
          server.protocol == 'stunnel-wireguard') {
        // ✅ FIXED: Local WireGuard servers
        _isUsingApiVpn.value = false;
        _serverSourceType.value = 'local-wireguard';

        // Tạo một Vpn object rỗng để clear data API
        vpn.value = Vpn.fromJson({
          'IP': server.ip,
          'CountryLong': server.countryName,
          'CountryShort': server.countryCode,
          'OpenVPN_ConfigData_Base64': '',
          'HostName': '',
          'Score': 0,
          'Ping': '', // ép sang String cho chắc chắn
          'Speed': 100,
          'NumVpnSessions': 0,
          'Uptime': 0,
          'TotalUsers': 0,
          'TotalTraffic': 0,
          'ConfigFileName': server.configFileName,
        });

        Pref.vpn = vpn.value;

        print('🧹 Set local WireGuard server');
      } else if (server.protocol == 'wireguard-api') {
        // ✅ FIXED: WireGuard API servers
        _isUsingApiVpn.value = true;
        _serverSourceType.value = 'api-wireguard';

        // Tạo Vpn object cho WireGuard API (không có OpenVPN config)
        vpn.value = Vpn.fromJson({
          'IP': server.ip,
          'CountryLong': server.countryName,
          'CountryShort': server.countryCode,
          'OpenVPN_ConfigData_Base64': '',
          'HostName': '',
          'Score': 0,
          'Ping': '',
          'NumVpnSessions': 0,
          'Uptime': 0,
          'TotalUsers': 0,
          'TotalTraffic': 0,
          'ConfigFileName': server.configFileName,
        });

        Pref.vpn = vpn.value;

        print('🌐 Set WireGuard API server');
      } else if (server.protocol == 'openvpn') {
        // ✅ FIXED: Local OpenVPN servers
        _isUsingApiVpn.value = false;
        _serverSourceType.value = 'local-vpn';

        // Chỉ tạo Vpn object cho OpenVPN
        final newVpn = await server.toVpn();
        vpn.value = newVpn;
        Pref.vpn = newVpn;

        print('📝 Set local OpenVPN server');
      }

      print('✅ Selected server: ${server.countryName} (${server.protocol})');
      print('   - isUsingApiVpn: ${_isUsingApiVpn.value}');
      print('   - serverSourceType: ${_serverSourceType.value}');
    } catch (e) {
      print('❌ Error setting local server: $e');
      _handleError('Failed to set VPN server', e);
    }
  }

  /// Set VPN from API server
  Future<void> setVpnFromApiServer(Vpn apiServer) async {
    try {
      print('🌐 Setting API server: ${apiServer.CountryLong}');

      // ✅ FIXED: Clear local server selection and set API flags
      selectedServer.value = null;
      _isUsingApiVpn.value = true;
      _serverSourceType.value = 'api-openvpn';

      // Set API VPN
      vpn.value = apiServer;
      Pref.vpn = apiServer;

      print('✅ Selected API server: ${apiServer.CountryLong}');
      print('   - isUsingApiVpn: ${_isUsingApiVpn.value}');
      print('   - serverSourceType: ${_serverSourceType.value}');
    } catch (e) {
      print('❌ Error setting API server: $e');
      _handleError('Failed to set API VPN server', e);
    }
  }

  // ===========================================
  // GETTERS FOR CURRENT SERVER INFO
  // ===========================================

  /// Get current country name (prioritize local server)
  String get currentCountry {
    final server = selectedServer.value;
    if (server != null) {
      return server.countryName;
    }
    return vpn.value.CountryLong;
  }

  /// Get current country code (prioritize local server)
  String get currentCountryShort {
    final server = selectedServer.value;
    if (server != null) {
      return server.countryCode;
    }
    return vpn.value.CountryShort;
  }

  /// Get current flag asset path
  String get currentFlagAsset {
    final code = currentCountryShort;
    if (code.isEmpty) return '';
    return 'assets/flags/${code.toLowerCase()}.png';
  }

  /// Check if currently using WireGuard protocol
  bool get isUsingWireGuard {
    final server = selectedServer.value;
    return server != null &&
        (server.protocol == 'wireguard' ||
            server.protocol == 'stunnel-wireguard' ||
            server.protocol == 'wireguard-api'); // ✅ NEW: Include API protocol
  }

  /// Check if currently using Stunnel protocol
  bool get isUsingStunnel {
    final server = selectedServer.value;
    return server != null && server.protocol == 'stunnel-wireguard';
  }

  /// ✅ FIXED: Check if using WireGuard API protocol
  bool get isUsingWireGuardApi {
    return _serverSourceType.value == 'api-wireguard';
  }

  /// ✅ FIXED: Check if using API VPN server - SIMPLE AND CLEAR
  bool get isUsingApiServer {
    print('🔍 Checking isUsingApiServer:');
    print('  - _isUsingApiVpn: ${_isUsingApiVpn.value}');
    print('  - _serverSourceType: ${_serverSourceType.value}');
    print(
        '  - selectedServer: ${selectedServer.value?.countryName} (${selectedServer.value?.protocol})');

    bool result = _isUsingApiVpn.value;
    print('  - Result: $result');
    return result;
  }

  /// ✅ NEW: Get server source type for detailed checking
  String get serverSourceType => _serverSourceType.value;

  /// ✅ NEW: Check if using OpenVPN API server
  bool get isUsingOpenVpnApiServer {
    return _serverSourceType.value == 'api-openvpn';
  }

  /// Get current server (local or create temp from API VPN)
  LocalVpnServer? get currentServer {
    final server = selectedServer.value;
    final apiVpn = vpn.value;

    if (server != null) {
      return server;
    } else if (isUsingOpenVpnApiServer) {
      // Create a temporary LocalVpnServer for OpenVPN API
      return LocalVpnServer(
        countryName: apiVpn.CountryLong,
        countryCode: apiVpn.CountryShort,
        ip: apiVpn.IP,
        ping: apiVpn.Ping,
        protocol: 'openvpn',
        configFileName: '',
        stunnelConfigFileName: '',
      );
    }
    return null;
  }

  // ===========================================
  // PRIVATE METHODS
  // ===========================================

  /// Set default server if current VPN config is empty
  void _setDefaultServerIfNeeded(List<LocalVpnServer> servers) {
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty && servers.isNotEmpty) {
      setVpnFromLocalServer(servers[0]);
    }
  }

  /// Handle errors with consistent logging
  void _handleError(String message, dynamic error) {
    print('VpnServerManager Error: $message - $error');
    onError?.call(message, error);
  }
}
