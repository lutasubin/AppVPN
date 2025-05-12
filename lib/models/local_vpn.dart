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

  LocalVpnServer({
    required this.countryName,
    required this.countryCode,
    required this.ip,
    required this.ping,
    required this.configFileName,
  });

  // Convert to Vpn model
  Future<Vpn> toVpn() async {
    // Load the OVPN file from assets
    final configData = await rootBundle.loadString('assets/vpn/$configFileName');
    
    // Convert to base64 for storage
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
  }
}