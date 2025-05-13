class Vpn {
  late final String HostName;
  late final String IP;
  late final int Score;
  late final String Ping;
  late final int Speed;
  late final String CountryLong;
  late final String CountryShort;
  late final int NumVpnSessions;
  late final int Uptime;
  late final int TotalUsers;
  late final int TotalTraffic;
  late final String OpenVPNConfigDataBase64;
  late final String ConfigFileName;
  
  Vpn({
    required this.HostName,
    required this.IP,
    required this.Score,
    required this.Ping,
    required this.Speed,
    required this.CountryLong,
    required this.CountryShort,
    required this.NumVpnSessions,
    required this.Uptime,
    required this.TotalUsers,
    required this.TotalTraffic,
   
    required this.OpenVPNConfigDataBase64,
    this.ConfigFileName = '', // Optional with default empty value
  });

  Vpn.fromJson(Map<String, dynamic> json) {
    HostName = json['HostName'] ?? '';
    IP = json['IP'] ?? '';
    Score = json['Score'] ?? 0;
    Ping = json['Ping']?.toString() ?? '0';
    Speed = json['Speed'] ?? 0;
    CountryLong = json['CountryLong'] ?? '';
    CountryShort = json['CountryShort'] ?? '';
    NumVpnSessions = json['NumVpnSessions'] ?? 0;
    Uptime = json['Uptime'] ?? 0;
    TotalUsers = json['TotalUsers'] ?? 0;
    TotalTraffic = json['TotalTraffic'] ?? 0;
   
    OpenVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
    ConfigFileName = json['ConfigFileName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = HostName;
    data['IP'] = IP;
    data['Score'] = Score;
    data['Ping'] = Ping;
    data['Speed'] = Speed;
    data['CountryLong'] = CountryLong;
    data['CountryShort'] = CountryShort;
    data['NumVpnSessions'] = NumVpnSessions;
    data['Uptime'] = Uptime;
    data['TotalUsers'] = TotalUsers;
    data['TotalTraffic'] = TotalTraffic;
    
    data['OpenVPN_ConfigData_Base64'] = OpenVPNConfigDataBase64;
    data['ConfigFileName'] = ConfigFileName;
    return data;
  }
}