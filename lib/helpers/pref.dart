import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vpn.dart';

class Pref {
  static late Box _box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('data');
  }

  

  static Vpn get vpn => Vpn.fromJson(jsonDecode(_box.get('vpn') ?? '{}'));
  static set vpn(Vpn v) => _box.put('vpn', jsonEncode(v));

  static List<Vpn> get vpnList {
    List<Vpn> temp = [];
    final data = jsonDecode(_box.get('vpnList') ?? '[]');

    for (var i in data) {
      temp.add(Vpn.fromJson(i));
    }
    
    return temp;
  }

  static set vpnList(List<Vpn> vpn) =>
      _box.put('vpnList', jsonEncode(vpn));

// Ngôn ngữ đã chọn
  static String get selectedLanguage => _box.get('selectedLanguage') ?? '';
  static set selectedLanguage(String value) => _box.put('selectedLanguage', value);

  
  static Future<void> storeCountryFlags(List<String> flags) async {
    await initializeHive(); // Ensure Hive is initialized
    await _box.put('countryFlags', jsonEncode(flags));
  }

  static List<String> getStoredCountryFlags() {
    final data = _box.get('countryFlags');
    return data != null ? List<String>.from(jsonDecode(data)) : [];
  }

  static Future<void> storeCountries(List<String> countries) async {
    await initializeHive(); // Ensure Hive is initialized
    await _box.put('countries', jsonEncode(countries));
  }

  static List<String> getStoredCountries() {
    final data = _box.get('countries');
    return data != null ? List<String>.from(jsonDecode(data)) : [];
  }

}