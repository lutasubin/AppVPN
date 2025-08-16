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
    countryName: 'Germany',
    countryCode: 'de',
    ip: '161.97.120.90.1',
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
    countryName: 'United States',
    countryCode: 'us',
    ip: '144.126.138.95.1',
    ping: '',
    configFileName: 'vpn-UsPro.ovpn',
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

final List<LocalVpnServer> fastVpn = [
  LocalVpnServer(
    countryName: 'Fast Speed',
    countryCode: '',
    ip: '222.222.222.2',
    ping: '',
    configFileName:
        wireguardVpn[randomIndex(wireguardVpn.length)].configFileName,
    protocol: 'wireguard',
  ),
];

// ✅ UPDATED: WireGuard servers từ assets (giữ nguyên để backward compatibility)
final List<LocalVpnServer> wireguardVpn = [
  LocalVpnServer(
    countryName: 'Germany',
    countryCode: 'de',
    ip: '213.136.95.11',
    ping: '',
    configFileName: 'vpn-germany5.conf',
    protocol: 'wireguard',
  ),
  LocalVpnServer(
    countryName: 'France',
    countryCode: 'fr',
    ip: '213.136.95.10',
    ping: '',
    configFileName: 'vpn-France20.conf',
    protocol: 'wireguard',
  ),
  LocalVpnServer(
    countryName: 'United States',
    countryCode: 'us',
    ip: '185.187.242.51',
    ping: '',
    configFileName: 'vpn-US20.conf',
    protocol: 'wireguard',
  ),
  LocalVpnServer(
    countryName: 'United Kingdom',
    countryCode: 'gb',
    ip: '209.126.15.51',
    ping: '',
    configFileName: 'vpn-US20.conf',
    protocol: 'wireguard',
  ),
  LocalVpnServer(
    countryName: 'Singapore',
    countryCode: 'sg',
    ip: '165.22.96.2',
    ping: '',
    configFileName: 'vpn-singapore3.conf',
    protocol: 'wireguard',
  ),
];

// ✅ NEW: WireGuard API servers - lấy config từ API thay vì assets
final List<LocalVpnServer> wireguardApiVpn = [
  LocalVpnServer(
    countryName: 'Germany',
    countryCode: 'de',
    ip: '81.0.220.147', // IP của API server
    ping: '',
    configFileName: '', // Không cần file name vì lấy từ API
    protocol: 'wireguard-api', // Protocol mới để phân biệt
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
