import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
// import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/models/vpn.dart';

class Apis {
  // Hàm kiểm tra kết nối internet
  static Future<bool> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false; // Không có kết nối
    }
    return true; // Có kết nối
  }
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = [];

    // Kiểm tra kết nối internet trước khi gọi API
    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      MyDialogs2.error(
        msg: 'no_internet'.tr, // Chuỗi "No Internet!" đã được dịch
        title: 'no_internet_title'.tr, // Tiêu đề tùy chọn, ví dụ: "Connection Error"
      );
      return vpnList; // Trả về danh sách rỗng nếu không có kết nối
    }

    try {
      final res = await get(Uri.parse(dotenv.env['VPN_FREE'] ?? ''));
      final csvString = res.body.split('#')[1].replaceAll('*', '');
      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];

      for (int i = 1; i < list.length - 1; ++i) {
        Map<String, dynamic> tempJson = {};

        for (int j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }
        vpnList.add(Vpn.fromJson(tempJson));
      }
      log(vpnList.first.HostName);
    } catch (e) {
      MyDialogs2.error(msg:'error_connect_server'.tr);
      log('\ngetVPNSeversE:$e');
    }
    // log(res.body);
    vpnList.shuffle();
    if (vpnList.isNotEmpty) {
      Pref.vpnList = vpnList;
    }
    return vpnList;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {

    // Kiểm tra kết nối internet trước khi gọi API
    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      MyDialogs2.error(
        msg: 'no_internet'.tr, // Chuỗi "No Internet!" đã được dịch
        title: 'no_internet_title'.tr, // Tiêu đề tùy chọn
      );
      return;
    }

    try {
      final res = await get(Uri.parse(dotenv.env['IP_FREE'] ?? ''));
      final data = jsonDecode(res.body);
      log(data.toString());
      ipData.value = IPDetails.fromJson(data);
    } catch (e) {
     MyDialogs2.error(
      msg:'error_connect_server'.tr
      );
      log('\ngetIPDetailsE: $e');
    }
  }
}
// Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36

// For Understanding Purpose

//*** CSV Data ***
// Name,    Country,  Ping
// Test1,   JP,       12
// Test2,   US,       112
// Test3,   IN,       7

//*** List Data ***
// [ [Name, Country, Ping], [Test1, JP, 12], [Test2, US, 112], [Test3, IN, 7] ]

//*** Json Data ***
// {"Name": "Test1", "Country": "JP", "Ping": 12}
