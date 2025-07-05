import 'dart:convert';
import 'package:flutter/services.dart';
import 'vpn.dart';

// Define a model for local VPN servers
class LocalVpnServer {
  final String countryName;
  final String countryCode;
  final String ip;
  final String ping;
  final String configFileName;
  final String protocol; // 'openvpn' hoặc 'wireguard'

  LocalVpnServer({
    required this.countryName,
    required this.countryCode,
    required this.ip,
    required this.ping,
    required this.configFileName,
    required this.protocol,
  });

  // Convert to Vpn model (chỉ dùng cho OpenVPN)
  Future<Vpn> toVpn() async {
    if (protocol == 'openvpn') {
      final configData =
          await rootBundle.loadString('assets/vpn/$configFileName');
      final configBase64 = base64Encode(utf8.encode(configData));
      return Vpn(
        HostName: '',
        IP: ip,
        Score: 0,
        Ping: ping,
        Speed: 100,
        CountryLong: countryName,
        CountryShort: countryCode,
        NumVpnSessions: 0,
        Uptime: 0,
        TotalUsers: 0,
        TotalTraffic: 0,
        OpenVPNConfigDataBase64: configBase64,
        ConfigFileName: configFileName,
      );
    } else {
      // WireGuard: chỉ trả về config dạng text, xử lý riêng ở controller
      final configData =
          await rootBundle.loadString('assets/wireguard/$configFileName');
      throw UnimplementedError('Use configData directly for WireGuard');
    }
  }
}
