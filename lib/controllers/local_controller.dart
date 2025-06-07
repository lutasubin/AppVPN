import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/local_vpn.dart';
import 'package:vpn_basic_project/apis/local_vpn_pro.dart';
import 'package:vpn_basic_project/apis/upload_downkoad.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
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

  // Timer chờ kết nối
  Timer? _waitingTimer;
  final RxInt remainingSeconds = 20.obs;

  // Check ngắt kết nối thủ công
  bool _manuallyDisconnected = false;

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
  }

  @override
  void onClose() {
    _cancelWaitingTimer();
    _vpnStageSub?.cancel();
    super.onClose();
  }

  /// Load available servers from predefined list
  /// In a real app, you might want to load this from a JSON file in assets
  void loadAvailableServers() {
    // Load predefined VPN servers
    // In a real app, you might want to load this from a JSON file in assets
    availableServers.value = highVpn;
    // If no VPN is selected, select the first one by default
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServers.isNotEmpty) {
      setVpnFromLocalServer(availableServers[0]);
    }
  }

  void loadAvailableServersPro() {
    // Load predefined VPN servers
    // In a real app, you might want to load this from a JSON file in assets
    availableServersPro.value = proVPN;
    // If no VPN is selected, select the first one by default
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServersPro.isNotEmpty) {
      setVpnFromLocalServer(availableServersPro[0]);
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

      _startWaitingTimer(); // Hiển thị UI chờ kết nối
      await VpnEngine.startVpn(vpnConfig); // Kết nối VPN
    } else {
      // Nếu đang kết nối VPN → hiển thị dialog ngắt kết nối
      showDisconnectDialogWithAd();
    }
  }

  /// Hiển thị dialog ngắt kết nối với quảng cáo
  void showDisconnectDialogWithAd() async {
    //   Get.dialog(
    //     WatchAdDialogDisconnect(
    //       onComplete: () async {
    //         await Future.delayed(Duration(milliseconds: 300)); // Cho UI ổn định
    //         Get.back(); // Đóng dialog
    //         await Future.delayed(Duration(milliseconds: 300)); // Cho UI ổn định
    _disconnectVpn(showWarning: false); // Ngắt VPN
    //       AdHelper.showInterstitialAd(
    //         onComplete: () {
    //           // Format thời gian kết nối
    //           String formattedTime = formatDuration(connectionDuration.value);

    //           // Điều hướng đến màn hình ngắt kết nối
    //           Get.to(() => DisconnectedScreen(
    //                 country: vpn.value.CountryLong,
    //                 ip: vpn.value.IP,
    //                 connectionTime: formattedTime,
    //                 uploadSpeed: getRandomUploadSpeed(),
    //                 downloadSpeed: getRandomDownloadSpeed(),
    //                 flagUrl:
    //                     'assets/flags/${vpn.value.CountryShort.toLowerCase()}.png',
    //               ));
    //         },
    //       );
    //     },
    //   ),
    // );
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

  /// Ngắt kết nối VPN
  void _disconnectVpn({bool showWarning = false}) async {
    _manuallyDisconnected = true;

    // Log disconnect event nếu có thời gian bắt đầu kết nối
    if (_connectionStartTime != null &&
        vpnState.value == VpnEngine.vpnConnected) {
      final durationInSeconds =
          DateTime.now().difference(_connectionStartTime!).inSeconds;
      AnalyticsHelper.logVpnDisconnect(
          vpn.value.CountryLong, durationInSeconds);
    }

    await VpnEngine.stopVpn();
    _cancelWaitingTimer(showWarning: showWarning);
  }

  /// Hẹn giờ đợi kết nối VPN (20s)
  void _startWaitingTimer() {
    _cancelWaitingTimer();
    _manuallyDisconnected = false;
    remainingSeconds.value = 20;

    _waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        update();
      } else {
        if (vpnState.value != VpnEngine.vpnConnected &&
            !_manuallyDisconnected) {
          VpnEngine.stopVpn();
          _cancelWaitingTimer(showWarning: true);
        }
      }
    });
  }

  /// Hủy timer + hiện cảnh báo nếu cần
  void _cancelWaitingTimer({bool showWarning = false}) {
    _waitingTimer?.cancel();
    _waitingTimer = null;
    if (showWarning) {
      MyDialogs2.warning(msg: 'warning'.tr);
    }
  }

  /// Lắng nghe sự kiện stage từ native
  void _listenVpnStage() {
    _vpnStageSub?.cancel();
    _vpnStageSub = VpnEngine.vpnStageSnapshot().listen((stage) {
      final stageLower = stage.toLowerCase();
      if (stageLower == VpnEngine.vpnConnected) {
        vpnState.value = VpnEngine.vpnConnected;
        _cancelWaitingTimer();
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
        _cancelWaitingTimer();
      }
      update();
    });
  }

  /// Đổi VPN server từ LocalVpnServer
  Future<void> setVpnFromLocalServer(LocalVpnServer server) async {
    final newVpn = await server.toVpn();
    vpn.value = newVpn;
    Pref.vpn = newVpn;
    _cancelWaitingTimer();
    // Log server selection event
    AnalyticsHelper.logServerSelection(server.countryName, server.countryCode);
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
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    }
  }

  /// Get button gradient based on VPN state
  LinearGradient getButtonGradient() {
    switch (vpnState.value) {
      case VpnEngine.vpnConnected:
        return LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case VpnEngine.vpnConnecting:
      case VpnEngine.vpnWaitConnection:
      case VpnEngine.vpnAuthenticating:
        return LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}
