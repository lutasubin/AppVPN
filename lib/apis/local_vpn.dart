import 'dart:math';
import 'package:vpn_basic_project/models/local_vpn.dart';

final List<LocalVpnServer> highVpn = [
  LocalVpnServer(
    countryName: 'United States',
    countryCode: 'us',
    ip: '144.126.138.95',
    ping: '',
    configFileName: 'vpn-US.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
        countryName: 'Canada',
        countryCode: 'ca',
        ip: '68.183.203.154',
        ping: '',
        configFileName: 'vpn-canada.ovpn', 
        protocol: 'openvpn',
      ),
  LocalVpnServer(
    countryName: 'United Kingdom',
    countryCode: 'gb',
    ip: '81.0.220.147',
    ping: '',
    configFileName: 'vpn-UK.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'Germany 1',
    countryCode: 'de',
    ip: '161.97.120.90',
    ping: '',
    configFileName: 'vpn-germanyctb.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'Germany 2',
    countryCode: 'de',
    ip: '161.97.120.90.1',
    ping: '',
    configFileName: 'vpn-germany5.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'French',
    countryCode: 'fr',
    ip: '62.171.171.217',
    ping: '',
    configFileName: 'vpn-francectb.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'Singapore',
    countryCode: 'sg',
    ip: '165.22.96.219',
    ping: '',
    configFileName: 'vpn-singapore5.ovpn',
    protocol: 'openvpn',
  ),
];

final List<LocalVpnServer> proVPN = [
  LocalVpnServer(
    countryName: 'United States',
    countryCode: 'us',
    ip: '144.126.138.95.1',
    ping: '',
    configFileName: 'vpn-UsPro.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'Germany',
    countryCode: 'de',
    ip: '161.97.120.90.10',
    ping: '',
    configFileName: 'vpn-germanyctb.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'French',
    countryCode: 'fr',
    ip: ' 161.97.120.90.1',
    ping: '',
    configFileName: 'vpn-francectb.ovpn',
    protocol: 'openvpn',
  ),
  LocalVpnServer(
    countryName: 'United Kingdom',
    countryCode: 'gb',
    ip: '81.0.220.147.1',
    ping: '',
    configFileName: 'vpn-UKPro.ovpn',
    protocol: 'openvpn',
  ),
  
  LocalVpnServer(
    countryName: 'Singapore',
    countryCode: 'sg',
    ip: '165.22.96.219.15',
    ping: '',
    configFileName: 'vpn-singapore5.ovpn',
    protocol: 'openvpn',
  ),
];

// ✅ NEW: WireGuard API servers - lấy config từ API thay vì assets
final List<LocalVpnServer> wireguardApiVpn = [
  LocalVpnServer(
    countryName: 'United Kingdom',
    countryCode: 'gb',
    ip: '81.0.220.147',
    ping: '',
    configFileName: '',
    protocol: 'wireguard-api',
  ),
  LocalVpnServer(
    countryName: 'Germany',
    countryCode: 'de',
    ip: '161.97.120.90',
    ping: '',
    configFileName: '',
    protocol: 'wireguard-api',
  ),
  LocalVpnServer(
    countryName: 'French',
    countryCode: 'fr',
    ip: '62.171.171.217',
    ping: '',
    configFileName: '',
    protocol: 'wireguard-api',
  ),
  LocalVpnServer(
    countryName: 'United States',
    countryCode: 'us',
    ip: '144.126.138.95',
    ping: '',
    configFileName: '',
    protocol: 'wireguard-api',
  ),
  LocalVpnServer(
    countryName: 'Singapore',
    countryCode: 'sg',
    ip: '51.79.144.227',
    ping: '',
    configFileName: '',
    protocol: 'wireguard-api',
  ),
];

// Hàm random index
int randomIndex(int length) => Random().nextInt(length);

// Danh sách server Stunnel + WireGuard
final List<LocalVpnServer> stunnelWireguardVpn = [
  LocalVpnServer(
    countryName: 'United States',
    countryCode: 'us',
    ip: '144.126.138.95',
    ping: '',
    configFileName: 'vpn_US22.conf',
    protocol: 'stunnel-wireguard',
    stunnelConfigFileName: 'stunnelclient.conf',
  ),
];
