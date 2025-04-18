import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/models/vpn.dart';

class Apis {
  /// Lấy danh sách VPN server từ API và lọc theo tiêu chí chất lượng
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = [];

    try {
      final response = await get(Uri.parse(dotenv.env['VPN_FREE'] ?? ''));
      final csvString = response.body.split('#')[1].replaceAll('*', '');
      final List<List<dynamic>> list =
          const CsvToListConverter().convert(csvString);

      final headers = list.first;

      // Parse từng dòng CSV thành object Vpn
      for (int i = 1; i < list.length - 1; ++i) {
        final Map<String, dynamic> jsonMap = {
          for (int j = 0; j < headers.length; ++j)
            headers[j].toString(): list[i][j],
        };
        vpnList.add(Vpn.fromJson(jsonMap));
      }

      log("Tổng số server: ${vpnList.length}");

      // Lọc server theo chất lượng: Score ≥ 100000, Ping ≤ 150ms, ưu tiên một số quốc gia
      final filteredList = vpnList
          .where((vpn) =>
              vpn.Score >= 100000 &&
              (int.tryParse(vpn.Ping) ?? 9999) <= 50 &&
              ['JP', 'SG', 'VN'].contains(vpn.CountryLong))
          .toList();

      // Sắp xếp theo Score giảm dần, Ping tăng dần
      filteredList.sort((a, b) {
        final scoreCompare = b.Score.compareTo(a.Score);
        return scoreCompare != 0 ? scoreCompare : a.Ping.compareTo(b.Ping);
      });

      log("Số server sau lọc: ${filteredList.length}");

      // Nếu không còn server nào đạt chuẩn thì dùng danh sách gốc
      final finalList = filteredList.isNotEmpty ? filteredList : vpnList;

      // Xáo trộn thêm để tránh bị trùng lặp mỗi lần load
      finalList.shuffle();

      // Lưu vào Pref
      Pref.vpnList = finalList;

      return finalList;
    } catch (e) {
      log('getVPNServers Error: $e');
      return vpnList;
    }
  }

  /// Lấy thông tin IP hiện tại của người dùng
  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final response = await get(Uri.parse(dotenv.env['IP_FREE'] ?? ''));
      final data = jsonDecode(response.body);
      log(data.toString());
      ipData.value = IPDetails.fromJson(data);
    } catch (e) {
      log('getIPDetails Error: $e');
    }
  }
}
