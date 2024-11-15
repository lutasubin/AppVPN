import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';

import '../apis/apis.dart';

class LocationController extends GetxController {
  var vpnList = Pref.vpnList;
  var filteredVpnList = <Vpn>[].obs;
  var isLoading = false.obs;

  Future<void> getVpnData() async {
    isLoading.value = true;
    vpnList.clear();
    vpnList.addAll(await Apis.getVPNServers());
    isLoading.value = false;
    filteredVpnList.value = vpnList;
  }


  //them vao
  void filterVpnList(String query) {
  print("Filtering with query: $query");
  print("Available VPNs: ${vpnList.map((vpn) => vpn.CountryLong).toList()}");

  if (query.isEmpty) {
    filteredVpnList.value = vpnList;
  } else {
    filteredVpnList.value = vpnList.where((vpn) {
      return vpn.CountryLong.toLowerCase().contains(query.toLowerCase()) || 
             vpn.HostName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  print("Filtered VPNs: ${filteredVpnList.map((vpn) => vpn.CountryLong).toList()}");
}
}