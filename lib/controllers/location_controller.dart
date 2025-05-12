import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import '../apis/apis.dart';

class LocationController extends GetxController {
  var vpnList = Pref.vpnList;
  var filteredVpnList = <Vpn>[].obs;
  var isLoading = false.obs;
  var isShareFreeMode = false.obs;


  
  // Theo dõi các quốc gia đã mở rộng
  var expandedCountries = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    filteredVpnList.value = vpnList;
    // Không mở mặc định bất kỳ quốc gia nào
  }


  // Tải danh sách VPN
  Future<void> getVpnData() async {
    isLoading.value = true;
    final servers = await Apis.getVPNServers();
    vpnList = servers;
    filteredVpnList.value = servers;
    Pref.vpnList = servers; // Lưu vào Hive
    isLoading.value = false;
  }

  // Lọc danh sách VPN theo từ khóa
  void filterVpnList(String query) {
    if (query.isEmpty) {
      filteredVpnList.value = vpnList;
    } else {
      filteredVpnList.value = vpnList.where((vpn) {
        return vpn.CountryLong.toLowerCase().contains(query.toLowerCase()) ||
               vpn.HostName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
  


  // Lấy tất cả các quốc gia duy nhất từ danh sách VPN
  List<String> getUniqueCountries() {
    final countries = <String>{};
    for (var vpn in vpnList) {
      countries.add(vpn.CountryLong);
    }
    return countries.toList();
  }
  

  
  // Chuyển đổi trạng thái mở rộng của quốc gia
  void toggleCountryExpansion(String country) {
    if (expandedCountries.contains(country)) {
      expandedCountries.remove(country);
    } else {
      expandedCountries.add(country);
    }
  }
  
  // Kiểm tra xem quốc gia có được mở rộng không
  bool isCountryExpanded(String country) {
    return expandedCountries.contains(country);
  }
}