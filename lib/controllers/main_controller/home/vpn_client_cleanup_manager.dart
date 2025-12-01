import 'dart:async';
import 'package:vpn_basic_project/apis/wireguard_service.dart';

/// Manager để xử lý cleanup client trên server khi disconnect VPN
class VpnClientCleanupManager {
  // ===========================================
  // PRIVATE PROPERTIES
  // ===========================================
  
  static VpnClientCleanupManager? _instance;
  final WireGuardService _wireGuardService = WireGuardService();
  
  // Track active clients by session
  final Map<String, ClientInfo> _activeClients = {};
  Timer? _cleanupTimer;
  
  // ===========================================
  // SINGLETON PATTERN
  // ===========================================
  
  static VpnClientCleanupManager get instance {
    _instance ??= VpnClientCleanupManager._internal();
    return _instance!;
  }
  
  VpnClientCleanupManager._internal() {
    _startPeriodicCleanup();
  }
  
  // ===========================================
  // PUBLIC METHODS
  // ===========================================
  
  /// Register a new client for tracking
  void registerClient(String clientName, String protocol, String serverId) {
    final clientInfo = ClientInfo(
      clientName: clientName,
      protocol: protocol,
      serverId: serverId,
      createdAt: DateTime.now(),
    );
    
    _activeClients[clientName] = clientInfo;
    print('📝 Registered client for tracking: $clientName ($protocol)');
  }
  
  /// Clean up specific client
  Future<bool> cleanupClient(String clientName) async {
    final clientInfo = _activeClients[clientName];
    
    if (clientInfo == null) {
      print('⚠️ Client $clientName not found in tracking');
      return true; // Consider success if not tracked
    }
    
    // Only cleanup WireGuard API clients
    if (clientInfo.protocol != 'wireguard-api') {
      print('ℹ️ Skipping cleanup for non-API client: $clientName (${clientInfo.protocol})');
      _activeClients.remove(clientName);
      return true;
    }
    
    try {
      print('🗑️ Cleaning up tracked client: $clientName');
      
      final success = await _wireGuardService.removeClientFromServer(clientName);
      
      if (success) {
        _activeClients.remove(clientName);
        print('✅ Client cleanup successful: $clientName');
        return true;
      } else {
        print('❌ Client cleanup failed: $clientName');
        return false;
      }
    } catch (e) {
      print('❌ Error during client cleanup: $e');
      return false;
    }
  }
  
  /// Clean up all tracked clients (emergency cleanup)
  Future<void> cleanupAllClients() async {
    if (_activeClients.isEmpty) {
      print('ℹ️ No clients to cleanup');
      return;
    }
    
    print('🗑️ Emergency cleanup of ${_activeClients.length} clients...');
    
    final clientNames = List<String>.from(_activeClients.keys);
    
    for (String clientName in clientNames) {
      try {
        await cleanupClient(clientName);
        // Small delay to avoid overwhelming server
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('⚠️ Failed to cleanup $clientName: $e');
      }
    }
    
    print('🎉 Emergency cleanup completed');
  }
  
  /// Clean up clients older than specified duration
  Future<void> cleanupOldClients({Duration maxAge = const Duration(hours: 1)}) async {
    final now = DateTime.now();
    final oldClients = _activeClients.entries
        .where((entry) => now.difference(entry.value.createdAt) > maxAge)
        .map((entry) => entry.key)
        .toList();
    
    if (oldClients.isEmpty) {
      print('ℹ️ No old clients found for cleanup');
      return;
    }
    
    print('🗑️ Cleaning up ${oldClients.length} old clients...');
    
    for (String clientName in oldClients) {
      try {
        await cleanupClient(clientName);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('⚠️ Failed to cleanup old client $clientName: $e');
      }
    }
    
    print('✅ Old client cleanup completed');
  }
  
  /// Get current tracked clients
  Map<String, ClientInfo> get activeClients => Map.unmodifiable(_activeClients);
  
  /// Check if client is tracked
  bool isClientTracked(String clientName) {
    return _activeClients.containsKey(clientName);
  }
  
  /// Get client info
  ClientInfo? getClientInfo(String clientName) {
    return _activeClients[clientName];
  }
  
  /// Force remove client from tracking (without server cleanup)
  void forceRemoveFromTracking(String clientName) {
    _activeClients.remove(clientName);
    print('🗑️ Force removed client from tracking: $clientName');
  }
  
  // ===========================================
  // PRIVATE METHODS
  // ===========================================
  
  /// Start periodic cleanup of old clients
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      print('⏰ Running periodic client cleanup...');
      cleanupOldClients();
    });
  }
  
  // ===========================================
  // LIFECYCLE METHODS
  // ===========================================
  
  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    // Emergency cleanup before disposal
    cleanupAllClients().catchError((e) {
      print('⚠️ Error during disposal cleanup: $e');
    });
    
    _activeClients.clear();
    print('🧹 VpnClientCleanupManager disposed');
  }
}

/// Information about a tracked client
class ClientInfo {
  final String clientName;
  final String protocol;
  final String serverId;
  final DateTime createdAt;
  
  ClientInfo({
    required this.clientName,
    required this.protocol,
    required this.serverId,
    required this.createdAt,
  });
  
  @override
  String toString() {
    return 'ClientInfo(name: $clientName, protocol: $protocol, server: $serverId, created: $createdAt)';
  }
  
  /// Get client age
  Duration get age => DateTime.now().difference(createdAt);
  
  /// Check if client is old
  bool isOlderThan(Duration duration) {
    return age > duration;
  }
}