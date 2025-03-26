import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../helpers/pref.dart';
import '../main.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../widgets/network_card.dart';
import '../apis/apis.dart';

class NetworkTestScreen extends StatelessWidget {
  const NetworkTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;
    Apis.getIPDetails(ipData: ipData);

    return Scaffold(
      backgroundColor: const Color(0xFF02091A), // Mã màu mới

      appBar: AppBar(
          backgroundColor: const Color(0xFF02091A), // Mã màu mới
          leading: IconButton(
            onPressed: () {
             Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFFFFFFFF),
              size: 25,
            ),
          ),
          title: Text(
            'IP Information'.tr,
            style: TextStyle(
                color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500),
          )),

      //refresh button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
            backgroundColor: Color(0xFFF15E24),
            onPressed: () {
              ipData.value = IPDetails.fromJson({});
              Apis.getIPDetails(ipData: ipData);
            },
            child: Icon(
              CupertinoIcons.refresh,
              color: const Color(0xFFFFFFFF),
              size: 30,
            )),
      ),

      body: Obx(
        () => ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
                left: mq.width * .04,
                right: mq.width * .04,
                top: mq.height * .01,
                bottom: mq.height * .1),
            children: [
              //ip
              NetworkCard(
                  data: NetworkData(
                      title: 'IP Address'.tr,
                      subtitle: ipData.value.query,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.blue))),
              SizedBox(
                height: 10,
              ),
              //isp
              NetworkCard(
                  data: NetworkData(
                      title: 'Internet Provider'.tr,
                      subtitle: ipData.value.isp,
                      icon: Icon(Icons.business, color: Colors.orange))),
              SizedBox(
                height: 10,
              ),
              //location
              NetworkCard(
                  data: NetworkData(
                      title: 'Location'.tr,
                      subtitle: ipData.value.country.isEmpty
                          ? 'Fetching ...'.tr
                          : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                      icon: Icon(CupertinoIcons.location, color: Colors.pink))),
              SizedBox(
                height: 10,
              ),
              //pin code
              NetworkCard(
                  data: NetworkData(
                      title: 'Pin-code'.tr,
                      subtitle: ipData.value.zip,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.cyan))),
              SizedBox(
                height: 10,
              ),
              //timezone
              NetworkCard(
                  data: NetworkData(
                      title: 'Timezone'.tr,
                      subtitle: ipData.value.timezone,
                      icon: Icon(CupertinoIcons.time, color: Colors.green))),
            ]),
      ),
    );
  }
}
