class Vpn {
  late final String HostName;
  late final String IP;
  // late final int Score;
  late final String Ping;
  late final int Speed;
  late final String CountryLong;
  late final String CountryShort;
  late final int NumVpnSessions;
  // late final int Uptime;
  // late final int TotalUsers;
  // late final int TotalTraffic;
  // late final String LogType;
  // late final String Operator;
  // late final String Message;
  late final String OpenVPNConfigDataBase64;
  Vpn({
    required this.HostName,
    required this.IP,
    // required this.Score,
    required this.Ping,
    required this.Speed,
    required this.CountryLong,
    required this.CountryShort,
    required this.NumVpnSessions,
    // required this.Uptime,
    // required this.TotalUsers,
    // required this.TotalTraffic,
    // required this.LogType,
    // required this.Operator,
    // required this.Message,
    required this.OpenVPNConfigDataBase64,
  });
  
  Vpn.fromJson(Map<String, dynamic> json){
    HostName = json['HostName'] ?? '';
    IP = json['IP'] ?? '';
    // Score = json['Score'] ?? 0;
    Ping = json['Ping'].toString();
    Speed = json['Speed'] ?? 0;
    CountryLong = json['CountryLong'] ?? '';
    CountryShort = json['CountryShort']?? '';
    NumVpnSessions = json['NumVpnSessions']?? 0;
    // Uptime = json['Uptime']?? '';
    // TotalUsers = json['TotalUsers']??'';
    // TotalTraffic = json['TotalTraffic']??'';
    // LogType = json['LogType']??'';
    // Operator = json['Operator']??'';
    // Message = json['Message']??'';
    OpenVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = HostName;
    data['IP'] = IP;
    // _data['Score'] = Score;
    data['Ping'] = Ping;
    data['Speed'] = Speed;
    data['CountryLong'] = CountryLong;
    data['CountryShort'] = CountryShort;
    data['NumVpnSessions'] = NumVpnSessions;
    // _data['Uptime'] = Uptime;
    // _data['TotalUsers'] = TotalUsers;
    // _data['TotalTraffic'] = TotalTraffic;
    // _data['LogType'] = LogType;
    // _data['Operator'] = Operator;
    // _data['Message'] = Message;
    data['OpenVPN_ConfigData_Base64'] = OpenVPNConfigDataBase64;
    return data;
  }
}