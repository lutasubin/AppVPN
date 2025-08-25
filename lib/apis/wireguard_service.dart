import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vpn_basic_project/helpers/remote_config/config_firebase.dart';

class WireGuardService {
  // ✅ NEW: Map IP addresses to their corresponding base URLs
  final Map<String, String> _ipToBaseUrl = {
    "81.0.220.147": Config.nuocAnh, // United Kingdom
    "144.126.138.95": Config.nuocMy, // United States
    "51.79.144.227": Config.nuocSin, // Singapore
    "62.171.171.217": Config.nuocPhap, // French
    "161.97.120.90": Config.nuocPhap, // Germany
  };

  final List<String> baseUrlList = [
    Config.nuocAnh, //United Kingdom
    Config.nuocMy, //United States
    Config.nuocSin, //Singapore
    Config.nuocPhap, //French
    Config.nuocPhap, //Germany
  ];

  // Default base URL (fallback)
  String baseUrl = "http://81.0.220.147:5000/wireguard";
  final String apiToken = Config.apiToken;

  // ✅ NEW: Current server IP for dynamic base URL selection
  String? _currentServerIp;

  /// ✅ NEW: Set the server IP to use appropriate base URL
  void setServerIp(String serverIp) {
    _currentServerIp = serverIp;

    // Update baseUrl based on server IP
    if (_ipToBaseUrl.containsKey(serverIp)) {
      baseUrl = _ipToBaseUrl[serverIp]!;
      print('🌍 Base URL updated for server $serverIp: $baseUrl');
    } else {
      // Fallback to default
      baseUrl = baseUrlList.first;
      print('⚠️ Unknown server IP $serverIp, using default base URL: $baseUrl');
    }
  }

  /// ✅ NEW: Get current base URL
  String getCurrentBaseUrl() {
    return baseUrl;
  }

  /// ✅ NEW: Get base URL for specific server IP
  String getBaseUrlForServer(String serverIp) {
    return _ipToBaseUrl[serverIp] ?? baseUrlList.first;
  }

  /// ========== [1] Sinh nhiều định dạng clientName để test ==========
  Map<String, String> _generateTestClientNames() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    final deviceId = Platform.isAndroid ? "android" : "ios";

    return {
      "simple": "client$random",
      "timestamp": "client_$timestamp",
      "full": "${deviceId}_${timestamp}_$random",
      "uuid_like":
          "client-${random.toString().padLeft(4, '0')}-${timestamp.toString().substring(timestamp.toString().length - 6)}",
      "short": "c$random",
    };
  }

  /// ========== [2] Tìm định dạng clientName hợp lệ ==========
  Future<String?> findValidClientName() async {
    final testNames = _generateTestClientNames();
    print("🔍 Testing different client name formats on $baseUrl...");

    for (final entry in testNames.entries) {
      final nameType = entry.key;
      final clientName = entry.value;

      print("📝 Trying '$clientName' (format: $nameType)");

      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/create'),
              headers: {
                'Authorization': apiToken,
                'Content-Type': 'application/json',
              },
              body: jsonEncode({"clientName": clientName}),
            )
            .timeout(const Duration(seconds: 15));

        print("   📡 Status: ${response.statusCode}");
        print("   📡 Body: ${response.body}");

        if (response.statusCode == 200) {
          print("   ✅ Name works!");
          return clientName;
        } else if (response.statusCode == 409) {
          print("   ⚠️ Name already exists");
          continue;
        }
      } catch (e) {
        print("   ❌ Error: $e");
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  /// ========== [3] MODIFIED: Lấy config từ server trả về String thay vì File ==========
  Future<String?> getValidatedConfigContent() async {
    try {
      print('🌐 Using base URL: $baseUrl');
      print('🌍 Current server IP: $_currentServerIp');

      // 1. Tìm clientName hợp lệ
      final validName = await findValidClientName();
      if (validName == null) {
        print('❌ No valid client name found');
        return null;
      }

      // 2. Đợi server xử lý (quan trọng!)
      print('⏳ Waiting for server to process config...');
      await Future.delayed(const Duration(seconds: 3));

      // 3. Lấy file config
      final response = await http
          .post(
            Uri.parse('$baseUrl/get-file'),
            headers: {
              'Authorization': apiToken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"clientName": validName}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('❌ Failed to get config file: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }

      // 4. Validate content before returning
      final configBytes = response.bodyBytes;
      if (configBytes.isEmpty) {
        print('❌ Config file is empty');
        return null;
      }

      // 5. Decode and clean config content
      String configContent = await _decodeAndCleanConfig(configBytes);

      if (configContent.isEmpty) {
        print('❌ Config content is empty after cleaning');
        return null;
      }

      // 6. Validate config
      if (!_isValidWireGuardConfig(configContent)) {
        print('❌ Invalid WireGuard config format');
        print('🔍 Raw config preview:');
        _debugPrintConfig(configContent);
        return null;
      }

      print('✅ Valid WireGuard config obtained');
      print('📊 Config size: ${configContent.length} characters');

      // 7. Return config content instead of saving to file
      return configContent;
    } catch (e) {
      print('❌ Error getting validated config: $e');
      return null;
    }
  }

  /// ========== [✅ NEW] Get config with client name for tracking ==========
  Future<Map<String, dynamic>?> getValidatedConfigWithClientName() async {
    try {
      print('🌐 Using base URL: $baseUrl');
      print('🌍 Current server IP: $_currentServerIp');

      // 1. Tìm clientName hợp lệ
      final validName = await findValidClientName();
      if (validName == null) {
        print('❌ No valid client name found');
        return null;
      }

      // 2. Đợi server xử lý (quan trọng!)
      print('⏳ Waiting for server to process config...');
      await Future.delayed(const Duration(seconds: 3));

      // 3. Lấy file config
      final response = await http
          .post(
            Uri.parse('$baseUrl/get-file'),
            headers: {
              'Authorization': apiToken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"clientName": validName}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('❌ Failed to get config file: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }

      // 4. Validate content before returning
      final configBytes = response.bodyBytes;
      if (configBytes.isEmpty) {
        print('❌ Config file is empty');
        return null;
      }

      // 5. Decode and clean config content
      String configContent = await _decodeAndCleanConfig(configBytes);

      if (configContent.isEmpty) {
        print('❌ Config content is empty after cleaning');
        return null;
      }

      // 6. Validate config
      if (!_isValidWireGuardConfig(configContent)) {
        print('❌ Invalid WireGuard config format');
        print('🔍 Raw config preview:');
        _debugPrintConfig(configContent);
        return null;
      }

      print('✅ Valid WireGuard config obtained with client tracking');
      print('👤 Client name: $validName');
      print('📊 Config size: ${configContent.length} characters');

      // 7. Return both config and client name
      return {
        'config': configContent,
        'clientName': validName,
        'serverIp': _currentServerIp,
        'baseUrl': baseUrl,
      };
    } catch (e) {
      print('❌ Error getting validated config with client name: $e');
      return null;
    }
  }

  // ========== [Rest of the methods remain the same] ==========

  Future<String> _decodeAndCleanConfig(List<int> configBytes) async {
    String configContent = '';

    try {
      configContent = utf8.decode(configBytes, allowMalformed: true);
    } catch (e) {
      try {
        configContent = latin1.decode(configBytes);
      } catch (e2) {
        print('❌ Failed to decode config with both UTF-8 and Latin-1: $e2');
        return '';
      }
    }

    configContent = _cleanConfigContent(configContent);
    print('🧹 Config cleaned, final length: ${configContent.length}');
    return configContent;
  }

  String _cleanConfigContent(String config) {
    print('🧹 Độ dài config gốc: ${config.length}');

    String cleaned = config
        .replaceAll(RegExp(r'\?\?[^[]*'), '')
        .replaceAll(RegExp(r'\?[^[]*'), '')
        .replaceAll(RegExp(r'build.*?conf'), '')
        .replaceAll(RegExp(r'Da tao.*?conf'), '')
        .replaceAll(RegExp(r'Peer server.*?conf'), '')
        .replaceAll('PK\n', '')
        .replaceAll('PK', '');

    final interfaceIndex = cleaned.indexOf('[Interface]');
    if (interfaceIndex == -1) {
      print('⚠️ Không tìm thấy section [Interface]');
      return '';
    }

    cleaned = cleaned.substring(interfaceIndex);

    final pngIndex = cleaned.indexOf('PNG');
    if (pngIndex != -1) {
      cleaned = cleaned.substring(0, pngIndex);
      print('🗑️ Đã loại bỏ dữ liệu PNG tại vị trí $pngIndex');
    }

    final lines = cleaned.split('\n');
    final cleanLines = <String>[];

    for (String line in lines) {
      line = line.trim();

      if (line.isEmpty) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        cleanLines.add(line);
        continue;
      }

      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();

          String cleanValue = value.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

          if (key.contains('Key') && cleanValue.length < 40) {
            print(
                '⚠️ Key "$key" có vẻ bị cắt ngắn: ${cleanValue.length} ký tự');
            final originalValue = line.substring(line.indexOf('=') + 1).trim();
            cleanValue = originalValue.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
          }

          if (cleanValue.isNotEmpty) {
            cleanLines.add('$key = $cleanValue');
          }
        }
      }
    }

    cleaned = cleanLines.join('\n');

    if (!cleaned.contains('[Interface]') || !cleaned.contains('[Peer]')) {
      print('❌ Thiếu section cần thiết sau khi làm sạch');
      return '';
    }

    print('🧹 Độ dài config sau làm sạch: ${cleaned.length}');
    return cleaned;
  }

  bool _isValidWireGuardConfig(String config) {
    final cleanConfig = config.trim();

    if (cleanConfig.isEmpty) {
      print('❌ Config trống');
      return false;
    }

    final requiredSections = ['[Interface]', '[Peer]'];
    final requiredInterfaceFields = ['PrivateKey', 'Address'];
    final requiredPeerFields = ['PublicKey', 'Endpoint'];

    for (final section in requiredSections) {
      if (!cleanConfig.contains(section)) {
        print('❌ Thiếu section cần thiết: $section');
        return false;
      }
    }

    final interfaceMatch = RegExp(r'\[Interface\](.*?)(?=\[|$)', dotAll: true)
        .firstMatch(cleanConfig);
    if (interfaceMatch != null) {
      final interfaceSection = interfaceMatch.group(1) ?? '';
      for (final field in requiredInterfaceFields) {
        if (!interfaceSection.contains(field)) {
          print('❌ Thiếu field Interface: $field');
          return false;
        }
      }

      final privateKeyMatch =
          RegExp(r'PrivateKey\s*=\s*([A-Za-z0-9+/]{40,}={0,2})')
              .firstMatch(interfaceSection);
      if (privateKeyMatch == null) {
        final keyLineMatch =
            RegExp(r'PrivateKey\s*=\s*(.+)').firstMatch(interfaceSection);
        if (keyLineMatch != null) {
          final keyValue = keyLineMatch.group(1)?.trim() ?? '';
          print(
              '❌ PrivateKey không hợp lệ. Tìm thấy: "${keyValue.length} ký tự"');
          print(
              '❌ Key preview: ${keyValue.length > 10 ? '${keyValue.substring(0, 10)}...' : keyValue}');
        } else {
          print('❌ Không tìm thấy dòng PrivateKey');
        }
        return false;
      }

      final addressMatch = RegExp(r'Address\s*=\s*([0-9./,\s:a-fA-F]+)')
          .firstMatch(interfaceSection);
      if (addressMatch == null) {
        print('❌ Định dạng Address không hợp lệ');
        return false;
      }
    } else {
      print('❌ Không thể parse section Interface');
      return false;
    }

    final peerMatch =
        RegExp(r'\[Peer\](.*?)(?=\[|$)', dotAll: true).firstMatch(cleanConfig);
    if (peerMatch != null) {
      final peerSection = peerMatch.group(1) ?? '';
      for (final field in requiredPeerFields) {
        if (!peerSection.contains(field)) {
          print('❌ Thiếu field Peer: $field');
          return false;
        }
      }

      final publicKeyMatch =
          RegExp(r'PublicKey\s*=\s*([A-Za-z0-9+/]{40,}={0,2})')
              .firstMatch(peerSection);
      if (publicKeyMatch == null) {
        final keyLineMatch =
            RegExp(r'PublicKey\s*=\s*(.+)').firstMatch(peerSection);
        if (keyLineMatch != null) {
          final keyValue = keyLineMatch.group(1)?.trim() ?? '';
          print(
              '❌ PublicKey không hợp lệ. Tìm thấy: "${keyValue.length} ký tự"');
          print('❌ PublicKey đầy đủ: "$keyValue"');
        } else {
          print('❌ Không tìm thấy dòng PublicKey');
        }
        return false;
      } else {
        print(
            '✅ PublicKey validation thành công: ${publicKeyMatch.group(1)?.length} ký tự');
      }

      final endpointMatch =
          RegExp(r'Endpoint\s*=\s*([0-9.]+:[0-9]+)').firstMatch(peerSection);
      if (endpointMatch == null) {
        print('❌ Định dạng Endpoint không hợp lệ');
        return false;
      }
    } else {
      print('❌ Không thể parse section Peer');
      return false;
    }

    print('✅ Validation config WireGuard thành công');
    return true;
  }

  void _debugPrintConfig(String config) {
    final lines = config.split('\n');
    print('📋 Debug config (${lines.length} dòng):');

    for (int i = 0; i < min(15, lines.length); i++) {
      final line = lines[i];
      if (line.trim().isNotEmpty) {
        if (line.contains('PrivateKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print(
                '  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ${keyValue.substring(0, min(8, keyValue.length))}...');
          } else {
            print('  Dòng ${i + 1}: $line');
          }
        } else if (line.contains('PublicKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print(
                '  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ${keyValue.substring(0, min(8, keyValue.length))}...');
            print('     🔍 PublicKey đầy đủ: "$keyValue"');
          } else {
            print('  Dòng ${i + 1}: $line');
          }
        } else if (line.contains('PresharedKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print(
                '  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ***ẨN***');
          } else {
            print('  Dòng ${i + 1}: $line');
          }
        } else {
          print(
              '  Dòng ${i + 1}: ${line.length > 50 ? '${line.substring(0, 50)}...' : line}');
        }
      } else {
        print('  Dòng ${i + 1}: [trống]');
      }
    }

    if (lines.length > 15) {
      print('  ... và ${lines.length - 15} dòng nữa');
    }
  }

  Future<String?> getConfigForVPN() async {
    print('🌐 Starting WireGuard API config retrieval...');
    print('🌍 Using server: $_currentServerIp -> $baseUrl');

    try {
      final configContent = await getValidatedConfigContent();

      if (configContent == null) {
        print('❌ Failed to get valid config from API');
        return null;
      }

      if (!_isValidWireGuardConfig(configContent)) {
        print('❌ Final validation failed');
        return null;
      }

      print('✅ WireGuard API config ready for VPN');
      return configContent;
    } catch (e) {
      print('❌ Error in getConfigForVPN: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getConfigDataWithClientName() async {
    print('🌐 Starting WireGuard API config retrieval with client tracking...');
    print('🌍 Using server: $_currentServerIp -> $baseUrl');

    try {
      final configData = await getValidatedConfigWithClientName();

      if (configData == null ||
          configData['config'] == null ||
          configData['clientName'] == null) {
        print('❌ Failed to get valid config with client name from API');
        return null;
      }

      final configContent = configData['config'] as String;

      if (!_isValidWireGuardConfig(configContent)) {
        print('❌ Final validation failed');
        return null;
      }

      print('✅ WireGuard API config ready for VPN with client tracking');
      print('👤 Client: ${configData['clientName']}');
      print('🌍 Server: ${configData['serverIp']} -> ${configData['baseUrl']}');

      return configData;
    } catch (e) {
      print('❌ Error in getConfigDataWithClientName: $e');
      return null;
    }
  }

  Future<bool> saveConfigToFile(String configContent, String fileName) async {
    try {
      final file = File(fileName);
      await file.writeAsString(configContent, encoding: utf8);
      print('💾 Config saved to: ${file.path}');
      return true;
    } catch (e) {
      print('❌ Error saving config: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> debugServer() async {
    final result = <String, dynamic>{};
    print("🔍 Starting server debug for: $baseUrl");

    try {
      final res = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));
      result['base'] = {'status': res.statusCode, 'body': res.body};
      print("✅ Base endpoint: ${res.statusCode}");
    } catch (e) {
      result['base'] = {'error': e.toString()};
    }

    try {
      final res = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': apiToken
      }).timeout(const Duration(seconds: 10));
      result['auth'] = {'status': res.statusCode, 'body': res.body};
      print("✅ Auth test: ${res.statusCode}");
    } catch (e) {
      result['auth'] = {'error': e.toString()};
    }

    return result;
  }

  Future<void> testCreateParameters() async {
    final paramsList = [
      {"clientName": "test123"},
      {"client": "test123"},
      {"name": "test123"},
      {"clientName": "test123", "serverPublicKey": "dummy"},
      {"clientName": "test123", "allowedIPs": "10.0.0.0/24"},
    ];

    print("🧪 Testing create parameters on $baseUrl");

    for (int i = 0; i < paramsList.length; i++) {
      final param = paramsList[i];
      print("📝 Test param ${i + 1}: ${jsonEncode(param)}");
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/create'),
              headers: {
                'Authorization': apiToken,
                'Content-Type': 'application/json',
              },
              body: jsonEncode(param),
            )
            .timeout(const Duration(seconds: 10));
        print("   📡 Status: ${res.statusCode} - ${res.body}");
        if (res.statusCode == 200) break;
      } catch (e) {
        print("   ❌ Error: $e");
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<bool> removeClientFromServer(String clientName) async {
    try {
      print('🗑️ Removing client "$clientName" from server $baseUrl...');

      final response = await http
          .post(
            Uri.parse('$baseUrl/remove'),
            headers: {
              'Authorization': apiToken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"clientName": clientName}),
          )
          .timeout(const Duration(seconds: 15));

      print('📡 Server response status: ${response.statusCode}');
      print('📡 Server response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Client "$clientName" removed from server successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('⚠️ Client "$clientName" not found on server (already removed?)');
        return true;
      } else {
        print('❌ Failed to remove client from server: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error removing client from server: $e');
      return false;
    }
  }

  Future<void> cleanupMultipleClients(List<String> clientNames) async {
    print(
        '🗑️ Cleaning up ${clientNames.length} clients from server $baseUrl...');

    for (String clientName in clientNames) {
      try {
        await removeClientFromServer(clientName);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('⚠️ Failed to cleanup client $clientName: $e');
      }
    }

    print('🎉 Batch cleanup completed');
  }

  Future<Map<String, dynamic>?> getServerStats() async {
    try {
      print('📊 Getting server statistics from $baseUrl...');

      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Authorization': apiToken,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body);
        print('📊 Server stats: $stats');
        return stats;
      } else {
        print('⚠️ Failed to get server stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting server stats: $e');
      return null;
    }
  }
}
