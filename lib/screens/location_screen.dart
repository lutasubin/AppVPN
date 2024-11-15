import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/main.dart';
import 'package:vpn_basic_project/screens/search_screen.dart';
import 'package:vpn_basic_project/widgets/vpn_cart.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});
  
  final LocationController _controller = Get.put(LocationController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty)  _controller.getVpnData();
    
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor:Pref.isDartMode?null: Colors.blue,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'VPN Locations(${_controller.vpnList.length})',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                 Get.to(() => SearchScreen());
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 27, 139, 231),
            onPressed: () {
              _controller.getVpnData();
            },
            child: Icon(
              CupertinoIcons.refresh,
              color: Colors.white,
            ),
          ),
        ),
        body: _controller.isLoading.value
            ? _loadingWidget(context)
            : _controller.vpnList.isEmpty
                ? _noVPNFound(context)
                : _vpnData(),
      ),
    );
  }

  
   
  

  
  _vpnData() => ListView.builder(
        itemCount: _controller.vpnList.length,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: mq.height * .015,
            bottom: mq.height * .1,
            left: mq.width * .04,
            right: mq.width * .04),
        itemBuilder: (ctx, i) => VpnCart(
          vpn: _controller.vpnList[i],
        ),
      );

  // Widget _noResultsFound() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Image.asset('assets/images/no_results.png'),
  //         SizedBox(height: 20),
  //         Text(
  //           'No results found for "${_searchController.text}"',
  //           style: TextStyle(fontSize: 18, color: Colors.black54),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _loadingWidget(BuildContext context) => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/lottie/loading.json',
              width: 200,
            ),
            Text(
              'Loading VPNs...😄',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _noVPNFound(BuildContext context) => Center(
        child: Text(
          'VPNs Not Found...😶',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
