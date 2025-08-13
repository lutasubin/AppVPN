import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WireGuardService {
  final String baseUrl = "http://81.0.220.147:5000/wireguard";

  // Hàm tạo config mới trên server
  Future<void> createConfig() async {
    print("🔄 Đang yêu cầu server tạo config mới...");
    final response = await http.post(Uri.parse('$baseUrl/create'));

    if (response.statusCode != 200) {
      throw Exception("❌ Tạo config thất bại: ${response.body}");
    }
    print("✅ Tạo config thành công!");
  }

  // Hàm tải file config (.conf) từ server
  Future<File> getConfigFile() async {
    print("📥 Đang tải file config từ server...");
    final response = await http.get(Uri.parse('$baseUrl/get-file'));

    if (response.statusCode != 200) {
      throw Exception("❌ Lấy file config thất bại");
    }

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/wg0.conf");
    await file.writeAsBytes(response.bodyBytes);

    print("💾 File config đã lưu tại: ${file.path}");
    return file;
  }
}
