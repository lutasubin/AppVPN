import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WireGuardService {
  final String baseUrl = "http://81.0.220.147:5000/wireguard";
  final String apiToken = "abc123456abccba";

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
    print("🔍 Testing different client name formats...");

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

  /// ========== [3] IMPROVED: Lấy config từ server với validation tốt hơn ==========
  Future<File?> getValidatedConfig() async {
    try {
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
      final response = await http.post(
        Uri.parse('$baseUrl/get-file'),
        headers: {
          'Authorization': apiToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"clientName": validName}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('❌ Failed to get config file: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }

      // 4. Validate content before saving
      final configBytes = response.bodyBytes;
      if (configBytes.isEmpty) {
        print('❌ Config file is empty');
        return null;
      }

      // 5. IMPROVED: Better decode and clean config content
      String configContent = await _decodeAndCleanConfig(configBytes);

      if (configContent.isEmpty) {
        print('❌ Config content is empty after cleaning');
        return null;
      }

      // 6. IMPROVED: Better validation
      if (!_isValidWireGuardConfig(configContent)) {
        print('❌ Invalid WireGuard config format');
        print('🔍 Raw config preview:');
        _debugPrintConfig(configContent);
        return null;
      }

      // 7. Save validated config
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/wg_$validName.conf");
      await file.writeAsString(configContent, encoding: utf8);
      
      print('✅ Valid WireGuard config saved: ${file.path}');
      print('📊 Config size: ${configContent.length} characters');
      
      return file;

    } catch (e) {
      print('❌ Error getting validated config: $e');
      return null;
    }
  }

  /// ========== [4] IMPROVED: Better config decode and clean ==========
  Future<String> _decodeAndCleanConfig(List<int> configBytes) async {
    String configContent = '';
    
    try {
      // Try UTF-8 first
      configContent = utf8.decode(configBytes, allowMalformed: true);
    } catch (e) {
      try {
        // Fallback to Latin-1 if UTF-8 fails
        configContent = latin1.decode(configBytes);
      } catch (e2) {
        print('❌ Failed to decode config with both UTF-8 and Latin-1: $e2');
        return '';
      }
    }

    // Clean the config content thoroughly
    configContent = _cleanConfigContent(configContent);
    
    print('🧹 Config cleaned, final length: ${configContent.length}');
    return configContent;
  }

  /// ========== [5] IMPROVED: Làm sạch config tốt hơn ==========
  String _cleanConfigContent(String config) {
    print('🧹 Độ dài config gốc: ${config.length}');
    
    // Bước 1: Loại bỏ phản hồi server và văn bản tiếng Việt
    String cleaned = config
        .replaceAll(RegExp(r'\?\?[^[]*'), '') // Loại bỏ "?? ang build l?i" patterns
        .replaceAll(RegExp(r'\?[^[]*'), '')   // Loại bỏ các ? patterns khác
        .replaceAll(RegExp(r'build.*?conf'), '') // Loại bỏ build messages
        .replaceAll(RegExp(r'Da tao.*?conf'), '') // Loại bỏ thông báo tiếng Việt
        .replaceAll(RegExp(r'Peer server.*?conf'), '') // Loại bỏ peer server messages
        .replaceAll('PK\n', '')               // Loại bỏ PK đơn lẻ
        .replaceAll('PK', '')                 // Loại bỏ PK prefix
        ;
    
    // Bước 2: Tìm vị trí bắt đầu và kết thúc config
    final interfaceIndex = cleaned.indexOf('[Interface]');
    if (interfaceIndex == -1) {
      print('⚠️ Không tìm thấy section [Interface]');
      return '';
    }
    
    // Bắt đầu từ [Interface]
    cleaned = cleaned.substring(interfaceIndex);
    
    // Bước 3: Loại bỏ dữ liệu PNG và mọi thứ sau nó (QR code)
    final pngIndex = cleaned.indexOf('PNG');
    if (pngIndex != -1) {
      // Tìm điểm cắt an toàn trước PNG
      cleaned = cleaned.substring(0, pngIndex);
      print('🗑️ Đã loại bỏ dữ liệu PNG tại vị trí $pngIndex');
    }
    
    // Bước 4: Xử lý từng dòng để bảo vệ các key hoàn chỉnh
    final lines = cleaned.split('\n');
    final cleanLines = <String>[];
    
    for (String line in lines) {
      line = line.trim();
      
      // Bỏ qua dòng trống
      if (line.isEmpty) continue;
      
      // Giữ nguyên section headers
      if (line.startsWith('[') && line.endsWith(']')) {
        cleanLines.add(line);
        continue;
      }
      
      // Xử lý dòng config (định dạng key = value)
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim(); // Để phòng trường hợp value có dấu =
          
          // Chỉ loại bỏ ký tự không in được khỏi value, KHÔNG cắt ngắn
          String cleanValue = value.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
          
          // Đảm bảo các key quan trọng không bị cắt ngắn
          if (key.contains('Key') && cleanValue.length < 40) {
            print('⚠️ Key "$key" có vẻ bị cắt ngắn: ${cleanValue.length} ký tự');
            // Thử tìm value đầy đủ trong dòng gốc
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
    
    // Bước 5: Kiểm tra có đủ section cần thiết
    if (!cleaned.contains('[Interface]') || !cleaned.contains('[Peer]')) {
      print('❌ Thiếu section cần thiết sau khi làm sạch');
      return '';
    }
    
    print('🧹 Độ dài config sau làm sạch: ${cleaned.length}');
    return cleaned;
  }


  /// ========== [7] IMPROVED: Validation WireGuard tốt hơn ==========
  bool _isValidWireGuardConfig(String config) {
    final cleanConfig = config.trim();
    
    if (cleanConfig.isEmpty) {
      print('❌ Config trống');
      return false;
    }
    
    // Kiểm tra cấu trúc WireGuard cơ bản
    final requiredSections = ['[Interface]', '[Peer]'];
    final requiredInterfaceFields = ['PrivateKey', 'Address'];
    final requiredPeerFields = ['PublicKey', 'Endpoint'];
    
    // 1. Kiểm tra các section cần thiết
    for (final section in requiredSections) {
      if (!cleanConfig.contains(section)) {
        print('❌ Thiếu section cần thiết: $section');
        return false;
      }
    }
    
    // 2. Kiểm tra section Interface
    final interfaceMatch = RegExp(r'\[Interface\](.*?)(?=\[|$)', dotAll: true).firstMatch(cleanConfig);
    if (interfaceMatch != null) {
      final interfaceSection = interfaceMatch.group(1) ?? '';
      for (final field in requiredInterfaceFields) {
        if (!interfaceSection.contains(field)) {
          print('❌ Thiếu field Interface: $field');
          return false;
        }
      }
      
      // Validation PrivateKey linh hoạt hơn (base64, ít nhất 40 ký tự)
      final privateKeyMatch = RegExp(r'PrivateKey\s*=\s*([A-Za-z0-9+/]{40,}={0,2})').firstMatch(interfaceSection);
      if (privateKeyMatch == null) {
        // Debug PrivateKey thực tế
        final keyLineMatch = RegExp(r'PrivateKey\s*=\s*(.+)').firstMatch(interfaceSection);
        if (keyLineMatch != null) {
          final keyValue = keyLineMatch.group(1)?.trim() ?? '';
          print('❌ PrivateKey không hợp lệ. Tìm thấy: "${keyValue.length} ký tự"');
          print('❌ Key preview: ${keyValue.length > 10 ? keyValue.substring(0, 10) + '...' : keyValue}');
        } else {
          print('❌ Không tìm thấy dòng PrivateKey');
        }
        return false;
      }
      
      // Validation định dạng Address (phải chứa IP/CIDR)
      final addressMatch = RegExp(r'Address\s*=\s*([0-9./,\s:a-fA-F]+)').firstMatch(interfaceSection);
      if (addressMatch == null) {
        print('❌ Định dạng Address không hợp lệ');
        return false;
      }
    } else {
      print('❌ Không thể parse section Interface');
      return false;
    }
    
    // 3. Kiểm tra section Peer  
    final peerMatch = RegExp(r'\[Peer\](.*?)(?=\[|$)', dotAll: true).firstMatch(cleanConfig);
    if (peerMatch != null) {
      final peerSection = peerMatch.group(1) ?? '';
      for (final field in requiredPeerFields) {
        if (!peerSection.contains(field)) {
          print('❌ Thiếu field Peer: $field');
          return false;
        }
      }
      
      // Validation PublicKey linh hoạt hơn
      final publicKeyMatch = RegExp(r'PublicKey\s*=\s*([A-Za-z0-9+/]{40,}={0,2})').firstMatch(peerSection);
      if (publicKeyMatch == null) {
        // Debug PublicKey thực tế
        final keyLineMatch = RegExp(r'PublicKey\s*=\s*(.+)').firstMatch(peerSection);
        if (keyLineMatch != null) {
          final keyValue = keyLineMatch.group(1)?.trim() ?? '';
          print('❌ PublicKey không hợp lệ. Tìm thấy: "${keyValue.length} ký tự"');
          print('❌ PublicKey đầy đủ: "$keyValue"');
          print('❌ Ký tự cuối: "${keyValue.length > 0 ? keyValue.substring(keyValue.length - min(5, keyValue.length)) : ''}"');
          
          // Kiểm tra ký tự không hợp lệ
          final invalidChars = keyValue.replaceAll(RegExp(r'[A-Za-z0-9+/=]'), '');
          if (invalidChars.isNotEmpty) {
            print('❌ PublicKey chứa ký tự không hợp lệ: "${invalidChars}"');
          }
        } else {
          print('❌ Không tìm thấy dòng PublicKey');
        }
        return false;
      } else {
        print('✅ PublicKey validation thành công: ${publicKeyMatch.group(1)?.length} ký tự');
      }
      
      // Validation định dạng Endpoint (IP:Port)
      final endpointMatch = RegExp(r'Endpoint\s*=\s*([0-9.]+:[0-9]+)').firstMatch(peerSection);
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

  /// ========== [8] NEW: Debug config printing - hiển thị tiếng Việt ==========
  void _debugPrintConfig(String config) {
    final lines = config.split('\n');
    print('📋 Debug config (${lines.length} dòng):');
    
    for (int i = 0; i < min(15, lines.length); i++) {
      final line = lines[i];
      if (line.trim().isNotEmpty) {
        // Để debug, hiển thị độ dài key thực tế
        if (line.contains('PrivateKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print('  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ${keyValue.substring(0, min(8, keyValue.length))}...');
          } else {
            print('  Dòng ${i + 1}: ${line}');
          }
        } else if (line.contains('PublicKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print('  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ${keyValue.substring(0, min(8, keyValue.length))}...');
            // Hiển thị toàn bộ PublicKey để debug
            print('     🔍 PublicKey đầy đủ: "$keyValue"');
          } else {
            print('  Dòng ${i + 1}: ${line}');
          }
        } else if (line.contains('PresharedKey')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            final keyValue = parts[1].trim();
            print('  Dòng ${i + 1}: ${parts[0].trim()} = [${keyValue.length} ký tự] ***ẨN***');
          } else {
            print('  Dòng ${i + 1}: ${line}');
          }
        } else {
          print('  Dòng ${i + 1}: ${line.length > 50 ? line.substring(0, 50) + '...' : line}');
        }
      } else {
        print('  Dòng ${i + 1}: [trống]');
      }
    }
    
    if (lines.length > 15) {
      print('  ... và ${lines.length - 15} dòng nữa');
    }
  }

  /// ========== [9] Method chính cho VPN connection ==========
  Future<File?> getConfigForVPN() async {
    print('🌐 Starting WireGuard API config retrieval...');
    
    try {
      final configFile = await getValidatedConfig();
      
      if (configFile == null) {
        print('❌ Failed to get valid config from API');
        return null;
      }
      
      // Đọc lại và validate lần cuối
      final finalContent = await configFile.readAsString();
      if (!_isValidWireGuardConfig(finalContent)) {
        print('❌ Final validation failed');
        await configFile.delete();
        return null;
      }
      
      print('✅ WireGuard API config ready for VPN');
      return configFile;
      
    } catch (e) {
      print('❌ Error in getConfigForVPN: $e');
      return null;
    }
  }

  /// ========== [10] Debug và test methods ==========
  Future<Map<String, dynamic>> debugServer() async {
    final result = <String, dynamic>{};
    print("🔍 Starting server debug...");

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
      final res = await http
          .get(Uri.parse(baseUrl), headers: {'Authorization': apiToken})
          .timeout(const Duration(seconds: 10));
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

  /// ========== [11] Cleanup method ==========
  Future<void> cleanup() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync().where((file) => 
          file.path.contains('wg_') && file.path.endsWith('.conf'));
      
      for (final file in files) {
        await file.delete();
        print('🗑️ Cleaned up: ${file.path}');
      }
    } catch (e) {
      print('⚠️ Cleanup error: $e');
    }
  }

  /// ========== [12] Additional helper methods ==========
  
  /// Create config with debug for testing
  Future<File?> createConfigWithDebug() async {
    final debugRes = await _runFullDebug();
    final validName = debugRes['valid_client_name'];
    if (validName == null) return null;

    final res = await http.post(
      Uri.parse('$baseUrl/get-file'),
      headers: {
        'Authorization': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"clientName": validName}),
    );

    if (res.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/wg_debug.conf");
      await file.writeAsBytes(res.bodyBytes);
      return file;
    }
    return null;
  }

  /// Get config with unique name for testing
  Future<File?> getConfigWithUniqueName() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    final clientName = "mobile_${timestamp}_$random";

    final createRes = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        'Authorization': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"clientName": clientName}),
    );

    if (createRes.statusCode != 200) return null;

    await Future.delayed(const Duration(seconds: 3));

    final getRes = await http.post(
      Uri.parse('$baseUrl/get-file'),
      headers: {
        'Authorization': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"clientName": clientName}),
    );

    if (getRes.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/wg_$clientName.conf");
      await file.writeAsBytes(getRes.bodyBytes);
      return file;
    }
    return null;
  }

  /// Run full debug process
  Future<Map<String, dynamic>> _runFullDebug() async {
    final results = <String, dynamic>{};
    results['server_debug'] = await debugServer();

    print("\n${"=" * 50}");
    await testCreateParameters();

    print("\n${"=" * 50}");
    final validName = await findValidClientName();
    results['valid_client_name'] = validName;

    if (validName != null) {
      try {
        final res = await http.post(
          Uri.parse('$baseUrl/get-file'),
          headers: {
            'Authorization': apiToken,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"clientName": validName}),
        );
        results['get_file'] = {
          'status': res.statusCode,
          'size': res.bodyBytes.length,
        };
      } catch (e) {
        results['get_file'] = {'error': e.toString()};
      }
    }

    return results;
  }
}