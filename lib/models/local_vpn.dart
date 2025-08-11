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
  final String protocol; // 'openvpn', 'wireguard', hoặc 'stunnel-wireguard'
  final String? stunnelConfigFileName; // Tên file cấu hình Stunnel (nếu có)

  LocalVpnServer({
    required this.countryName,
    required this.countryCode,
    required this.ip,
    required this.ping,
    required this.configFileName,
    required this.protocol,
    this.stunnelConfigFileName,
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
      // WireGuard hoặc Stunnel-WireGuard: chỉ trả về config dạng text, xử lý riêng ở controller
      throw UnimplementedError('Use configData directly for WireGuard/Stunnel');
    }
  }

  // Kiểm tra xem có sử dụng Stunnel không
  bool get usesStunnel => protocol == 'stunnel-wireguard' && stunnelConfigFileName != null;

 // Create object from JSON map
  factory LocalVpnServer.fromJson(Map<String, dynamic> json) {
    return LocalVpnServer(
      countryName: json['countryName'],
      countryCode: json['countryCode'],
      ip: json['ip'],
      ping: json['ping'],
      configFileName: json['configFileName'],
      protocol: json['protocol'],
      stunnelConfigFileName: json['stunnelConfigFileName'],
    );
  }
}
