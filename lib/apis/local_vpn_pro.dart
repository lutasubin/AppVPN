import 'package:vpn_basic_project/models/local_vpn.dart';

final List<LocalVpnServer> proVPN = [
  LocalVpnServer(
    countryName: 'Mexico - Mexicocity',
    countryCode: 'mx',
    ip: '216.238.70.29',
    ping: '',
    configFileName: 'vpn-mexicocity.ovpn',
  ),
  LocalVpnServer(
    countryName: 'Brazil - São Paulo',
    countryCode: 'br',
    ip: '216.238.122.7',
    ping: '',
    configFileName: 'vpn-saopaulo.ovpn',
  ),
];
