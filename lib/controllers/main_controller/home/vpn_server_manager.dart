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
  
  // Server lists
  final RxList<LocalVpnServer> availableServers = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableServersPro = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableServersFast = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableWireGuardServers = <LocalVpnServer>[].obs;
  final RxList<LocalVpnServer> availableStunnelWireGuardServers = <LocalVpnServer>[].obs;
  
  // ✅ NEW: WireGuard API servers
  final RxList<LocalVpnServer> availableWireGuardApiServers = <LocalVpnServer>[].obs;
  
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
      loadAvailableServersFast();
      loadAvailableWireGuardServers();
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
  
  /// Load fast VPN servers
  void loadAvailableServersFast() {
    try {
      availableServersFast.value = fastVpn;
      _setDefaultServerIfNeeded(availableServersFast);
    } catch (e) {
      _handleError('Failed to load fast servers', e);
    }
  }
  
  /// Load WireGuard servers (from assets)
  void loadAvailableWireGuardServers() {
    try {
      availableWireGuardServers.value = wireguardVpn;
      print('✅ Loaded ${wireguardVpn.length} WireGuard (assets) servers');
    } catch (e) {
      _handleError('Failed to load WireGuard servers', e);
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
      final servers = await Apis.getVPNServers();
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
      print('🔧 Setting local server: ${server.countryName} (${server.protocol})');
      
      // Set server mới
      selectedServer.value = server;
      
      // ✅ UPDATED: Handle different protocols including wireguard-api
      if (server.protocol == 'wireguard' || 
          server.protocol == 'stunnel-wireguard' ||
          server.protocol == 'wireguard-api') { // ✅ NEW: Support API protocol
        
        // Tạo một Vpn object rỗng để clear data API
        vpn.value = Vpn.fromJson({
          'IP': server.ip,
          'CountryLong': server.countryName,
          'CountryShort': server.countryCode,
          'OpenVPN_ConfigData_Base64': '',
          'HostName': '',
          'Score': '0',
          'Ping': server.ping,
          'Speed': '100',
          'NumVpnSessions': '0',
          'Uptime': '0',
          'TotalUsers': '0',
          'TotalTraffic': '0',
          'ConfigFileName': server.configFileName,
        });
        Pref.vpn = vpn.value;
        
        if (server.protocol == 'wireguard-api') {
          print('🌐 Prepared WireGuard API server');
        } else {
          print('🧹 Cleared API VPN data for local server');
        }
        
      } else if (server.protocol == 'openvpn') {
        // Chỉ tạo Vpn object cho OpenVPN
        final newVpn = await server.toVpn();
        vpn.value = newVpn;
        Pref.vpn = newVpn;
        
        print('📝 Created VPN config for OpenVPN server');
      }
      
      print('✅ Selected server: ${server.countryName} (${server.protocol})');
    } catch (e) {
      print('❌ Error setting local server: $e');
      _handleError('Failed to set VPN server', e);
    }
  }
  
  /// Set VPN from API server 
  Future<void> setVpnFromApiServer(Vpn apiServer) async {
    try {
      print('🌐 Setting API server: ${apiServer.CountryLong}');
      
      // Clear local server selection
      selectedServer.value = null;
      
      // Set API VPN
      vpn.value = apiServer;
      Pref.vpn = apiServer;
      
      print('✅ Selected API server: ${apiServer.CountryLong}');
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
  
  /// ✅ UPDATED: Check if using WireGuard API protocol
  bool get isUsingWireGuardApi {
    final server = selectedServer.value;
    return server != null && server.protocol == 'wireguard-api';
  }
  
  /// ✅ FIX: Check if using API VPN server - FIXED LOGIC
  bool get isUsingApiServer {
    final server = selectedServer.value;
    
    print('🔍 Checking isUsingApiServer:');
    print('  - selectedServer: ${server?.countryName} (${server?.protocol})');
    print('  - vpn.IP: ${vpn.value.IP}');
    print('  - vpn.OpenVPNConfig: ${vpn.value.OpenVPNConfigDataBase64.isNotEmpty}');
    
    // Logic đơn giản và rõ ràng:
    // - Nếu có selectedServer với protocol wireguard-api → là WireGuard API server
    // - Nếu không có selectedServer và có API VPN data → là OpenVPN API server
    bool result = (server != null && server.protocol == 'wireguard-api') ||
                  (server == null && 
                   vpn.value.IP.isNotEmpty && 
                   vpn.value.OpenVPNConfigDataBase64.isNotEmpty);
    
    print('  - Result: $result');
    return result;
  }
  
  /// Get current server (local or create temp from API VPN)
  LocalVpnServer? get currentServer {
    final server = selectedServer.value;
    final apiVpn = vpn.value;
    
    if (server != null) {
      return server;
    } else if (isUsingApiServer && !isUsingWireGuardApi) {
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