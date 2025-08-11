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
      // Uncomment these if needed
      // loadAvailableServersFast();
      // loadAvailableWireGuardServers();
      // loadAvailableStunnelWireGuardServers();
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
  
  // /// Load fast VPN servers
  // void loadAvailableServersFast() {
  //   try {
  //     availableServersFast.value = fastVpn;
  //     _setDefaultServerIfNeeded(availableServersFast);
  //   } catch (e) {
  //     _handleError('Failed to load fast servers', e);
  //   }
  // }
  
  // /// Load WireGuard servers
  // void loadAvailableWireGuardServers() {
  //   try {
  //     availableWireGuardServers.value = wireguardVpn;
  //   } catch (e) {
  //     _handleError('Failed to load WireGuard servers', e);
  //   }
  // }
  
  /// Load Stunnel + WireGuard servers
  // void loadAvailableStunnelWireGuardServers() {
  //   try {
  //     availableStunnelWireGuardServers.value = stunnelWireguardVpn;
  //     print('✅ Loaded ${stunnelWireguardVpn.length} Stunnel-WireGuard servers');
  //     for (var server in stunnelWireguardVpn) {
  //       print('  - ${server.countryName} (${server.protocol})');
  //     }
  //   } catch (e) {
  //     print('❌ Error loading Stunnel-WireGuard servers: $e');
  //     _handleError('Failed to load Stunnel-WireGuard servers', e);
  //   }
  // }
  
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
      // Set server mới
      selectedServer.value = server;
      
      // Chỉ tạo Vpn object cho OpenVPN
      if (server.protocol == 'openvpn') {
        final newVpn = await server.toVpn();
        vpn.value = newVpn;
        Pref.vpn = newVpn;
      }
      
      print('✅ Selected server: ${server.countryName} (${server.protocol})');
    } catch (e) {
      _handleError('Failed to set VPN server', e);
    }
  }
  
  // ===========================================
  // GETTERS FOR CURRENT SERVER INFO
  // ===========================================
  
  /// Get current country name (prioritize WireGuard and Stunnel-WireGuard)
  String get currentCountry {
    final server = selectedServer.value;
    if (server != null && 
        (server.protocol == 'wireguard' || server.protocol == 'stunnel-wireguard')) {
      return server.countryName;
    }
    return vpn.value.CountryLong;
  }
  
  /// Get current country code (prioritize WireGuard and Stunnel-WireGuard)
  String get currentCountryShort {
    final server = selectedServer.value;
    if (server != null && 
        (server.protocol == 'wireguard' || server.protocol == 'stunnel-wireguard')) {
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
        (server.protocol == 'wireguard' || server.protocol == 'stunnel-wireguard');
  }
  
  /// Check if currently using Stunnel protocol
  bool get isUsingStunnel {
    final server = selectedServer.value;
    return server != null && server.protocol == 'stunnel-wireguard';
  }
  
  /// Check if using API VPN server
  bool get isUsingApiServer {
    final server = selectedServer.value;
    final apiVpn = vpn.value;
    
    return apiVpn.IP.isNotEmpty && 
           apiVpn.OpenVPNConfigDataBase64.isNotEmpty && 
           (server == null || server.ip != apiVpn.IP);
  }
  
  /// Get current server (local or create temp from API VPN)
  LocalVpnServer? get currentServer {
    final server = selectedServer.value;
    final apiVpn = vpn.value;
    
    if (server != null) {
      return server;
    } else if (isUsingApiServer) {
      // Create a temporary LocalVpnServer for API VPN
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