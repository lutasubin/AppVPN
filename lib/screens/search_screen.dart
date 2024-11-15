import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';
import 'package:vpn_basic_project/widgets/vpn_cart.dart';

class SearchScreen extends StatelessWidget {
  final LocationController _controller = Get.find<LocationController>();
  final TextEditingController _searchController = TextEditingController();

  Widget _noResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_results.png'),
          SizedBox(height: 20),
          Text(
            'No results found for "${_searchController.text}"',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search VPN'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter location...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _controller.filterVpnList(value);
                },
              ),
            ),
            Obx(() {
              final filteredList = _controller.filteredVpnList;
              return filteredList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (ctx, i) => GestureDetector(
                        onTap: () {
                          Get.off(() => HomeScreen());
                        },
                        child: VpnCart(
                          vpn: filteredList[i],
                        ),
                      ),
                    )
                  : _noResultsFound();
            }),
          ],
        ),
      ),
    );
  }
} 