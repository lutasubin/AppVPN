import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/local_vpn.dart';
import 'package:vpn_basic_project/apis/upload_downkoad.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/screens/disconected_screen.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/watch_video_disconnect.dart';

import '../screens/rate_screen.dart';

class LocalController extends GetxController {
  // VPN đang chọn
  final Rx<Vpn> vpn = Pref.vpn.obs;

  // Trạng thái VPN hiện tại
  final vpnState = VpnEngine.vpnDisconnected.obs;

  // List of available local VPN servers
  final RxList<LocalVpnServer> availableServers = <LocalVpnServer>[].obs;

  // List of available local VPN pro servers
  final RxList<LocalVpnServer> availableServersPro = <LocalVpnServer>[].obs;

  // List of available local VPN fast servers
  final RxList<LocalVpnServer> availableServersFast = <LocalVpnServer>[].obs;

  // Lắng nghe stage từ native
  StreamSubscription<String>? _vpnStageSub;

  // Thời gian bắt đầu kết nối
  DateTime? _connectionStartTime;

  final connectionDuration = Duration().obs;

  @override
  void onInit() {
    super.onInit();
    _listenVpnStage();
    loadAvailableServers();
    loadAvailableServersPro();
    loadAvailableServersFast();
  }

  @override
  void onClose() {
    _vpnStageSub?.cancel();
    super.onClose();
  }

  //Load highVpn
  void loadAvailableServers() {
    availableServers.value = highVpn;
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServers.isNotEmpty) {
      setVpnFromLocalServer(availableServers[0]);
    }
  }

  //Load vpnPro
  void loadAvailableServersPro() {
    availableServersPro.value = proVPN;
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServersPro.isNotEmpty) {
      setVpnFromLocalServer(availableServersPro[0]);
    }
  }

  void loadAvailableServersFast() {
    availableServersFast.value = fastVpn;
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServersPro.isNotEmpty) {
      setVpnFromLocalServer(availableServersFast[0]);
    }
  }

  //Connect vpn
  void connectToVpn() async {
    // Nếu chưa chọn location VPN
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    // Nếu VPN đang ở trạng thái ngắt kết nối → kết nối mới
    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);

      final vpnConfig = VpnConfig(
        country: vpn.value.CountryLong,
        username: '',
        password: '',
        config: config,
      );
      await VpnEngine.startVpn(vpnConfig); // Kết nối VPN
    } else {
      disconnectVpn();
    }
  }

  // /// Hiển thị dialog ngắt kết nối với quảng cáo
  // void showDisconnectDialogWithAd() async {
  //   Get.dialog(
  //     WatchAdDialogDisconnect(
  //       onComplete: () async {
  //         await Future.delayed(Duration(milliseconds: 300)); // Cho UI ổn định
  //         Get.back(); // Đóng dialog
  //         await Future.delayed(Duration(milliseconds: 300)); // Cho UI ổn định
  //        disconnectVpn();
  //         AdHelper.showInterstitialAd(
  //           onComplete: () {
  //             // Format thời gian kết nối
  //             String formattedTime = formatDuration(connectionDuration.value);
  //             // Điều hướng đến màn hình ngắt kết nối
  //             Get.to(() => DisconnectedScreen(
  //                   country: vpn.value.CountryLong,
  //                   ip: vpn.value.IP,
  //                   connectionTime: formattedTime,
  //                   uploadSpeed: getRandomUploadSpeed(),
  //                   downloadSpeed: getRandomDownloadSpeed(),
  //                   flagUrl:
  //                       'assets/flags/${vpn.value.CountryShort.toLowerCase()}.png',
  //                 ));
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  /// Ngắt kết nối VPN
  void disconnectVpn() async {
    // Log disconnect event nếu có thời gian bắt đầu kết nối
    if (_connectionStartTime != null &&
        vpnState.value == VpnEngine.vpnConnected) {
      final durationInSeconds =
          DateTime.now().difference(_connectionStartTime!).inSeconds;
      AnalyticsHelper.logVpnDisconnect(
          vpn.value.CountryLong, durationInSeconds);
    }

    await VpnEngine.stopVpn();
  }

  /// Đếm số lần nhấn nút kết nối và kiểm tra hiển thị rating
  void incrementConnectionAttempts(BuildContext context) {
    // Chỉ hiển thị rating nếu chưa hiển thị trước đây
    if (!Pref.hasShownRating) {
      int attempts = Pref.connectionAttempts + 1;
      Pref.connectionAttempts = attempts;

      // Kiểm tra nếu đã nhấn nút kết nối 3 lần
      if (attempts >= 3) {
        // Đặt lịch hiển thị màn hình rating sau 1 giây
        Future.delayed(Duration(seconds: 1), () {
          showRatingScreen(context);
        });
      }
    }
  }

  /// Hiển thị màn hình rating
  void showRatingScreen(BuildContext context) {
    // Đánh dấu đã hiển thị rating
    Pref.hasShownRating = true;

    // Reset số lần nhấn nút kết nối
    Pref.resetConnectionAttempts();

    // Hiển thị màn hình rating
    showRatingBottomSheet2(context);
  }

  void showRatingBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => const RatingBottomSheet(),
    );
  }

  /// Lắng nghe sự kiện stage từ native
  void _listenVpnStage() {
    _vpnStageSub?.cancel();
    _vpnStageSub = VpnEngine.vpnStageSnapshot().listen((stage) {
      final stageLower = stage.toLowerCase();
      if (stageLower == VpnEngine.vpnConnected) {
        vpnState.value = VpnEngine.vpnConnected;
        // Ghi nhận thời gian bắt đầu kết nối và log sự kiện
        _connectionStartTime = DateTime.now();
        AnalyticsHelper.logVpnConnect(
            vpn.value.CountryLong, vpn.value.CountryShort);
      } else if (stageLower == VpnEngine.vpnDisconnected) {
        // Log disconnect event nếu có thời gian bắt đầu kết nối
        if (_connectionStartTime != null &&
            vpnState.value == VpnEngine.vpnConnected) {
          final durationInSeconds =
              DateTime.now().difference(_connectionStartTime!).inSeconds;
          AnalyticsHelper.logVpnDisconnect(
              vpn.value.CountryLong, durationInSeconds);
          _connectionStartTime = null;
        }
        vpnState.value = VpnEngine.vpnDisconnected;
      }
      update();
    });
  }

  /// Đổi VPN server từ LocalVpnServer
  Future<void> setVpnFromLocalServer(LocalVpnServer server) async {
    if (vpnState.value == VpnEngine.vpnConnected) {
      VpnEngine.stopVpn();
    }
    final newVpn = await server.toVpn();
    vpn.value = newVpn;
    Pref.vpn = newVpn;
    // Log server selection event
    AnalyticsHelper.logServerSelection(server.countryName, server.countryCode);

    update();
  }

  // Helper method to format duration as HH:MM:SS
  String formatDuration(Duration duration) {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigit(duration.inHours);
    final minutes = twoDigit(duration.inMinutes.remainder(60));
    final seconds = twoDigit(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Nội dung nút kết nối - Updated for new design
  Widget get getButtonContent {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
      case VpnEngine.vpnPrepare:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect'.tr,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case VpnEngine.vpnConnected:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Text(
              'Connected'.tr,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case VpnEngine.vpnConnecting ||
            VpnEngine.vpnWaitConnection ||
            VpnEngine.vpnAuthenticating:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Text(
              'Connecting....'.tr,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Waiting....'.tr,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }

  /// Get button gradient based on VPN state
  LinearGradient getButtonGradient() {
    List<Color> connectedColors = [
      Color(0xFF4CAF50),
      Color(0xFF1976D2),
    ];

    switch (vpnState.value) {
      case VpnEngine.vpnConnected:
        return LinearGradient(
          colors: connectedColors,
          stops: List.generate(
              connectedColors.length, (i) => i / (connectedColors.length - 1)),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return LinearGradient(
          stops: List.generate(
              connectedColors.length, (i) => i / (connectedColors.length - 1)),
          colors: connectedColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}
