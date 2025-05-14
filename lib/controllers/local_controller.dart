import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/cowndowncircle.dart';

import '../screens/rate_screen.dart';

class LocalController extends GetxController {
  // VPN đang chọn
  final Rx<Vpn> vpn = Pref.vpn.obs;

  // Trạng thái VPN hiện tại
  final vpnState = VpnEngine.vpnDisconnected.obs;

  // List of available local VPN servers
  final RxList<LocalVpnServer> availableServers = <LocalVpnServer>[].obs;

  // Timer chờ kết nối
  Timer? _waitingTimer;
  final RxInt _remainingSeconds = 20.obs;

  // Check ngắt kết nối thủ công
  bool _manuallyDisconnected = false;

  // Lắng nghe stage từ native
  StreamSubscription<String>? _vpnStageSub;

  // Thời gian bắt đầu kết nối
  DateTime? _connectionStartTime;

  @override
  void onInit() {
    super.onInit();
    _listenVpnStage();
    loadAvailableServers();
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
    availableServers.value = [
      LocalVpnServer(
        countryName: 'United States',
        countryCode: 'us',
        ip: '134.209.119.77',
        ping: '',
        configFileName: 'us_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'United Kingdom',
        countryCode: 'gb',
        ip: '178.128.164.174',
        ping: '',
        configFileName: 'uk_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'Japan',
        countryCode: 'jp',
        ip: '219.100.37.169',
        ping: '',
        configFileName: 'jp_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'Germany',
        countryCode: 'de',
        ip: '178.128.207.219',
        ping: '',
        configFileName: 'de_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'Singapore',
        countryCode: 'sg',
        ip: '165.22.96.219',
        ping: '',
        configFileName: 'sg_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'Canada',
        countryCode: 'ca',
        ip: '68.183.203.154',
        ping: '',
        configFileName: 'ca_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'Australia',
        countryCode: 'au',
        ip: '170.64.162.198',
        ping: '',
        configFileName: 'au_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'India',
        countryCode: 'in',
        ip: '142.93.219.152',
        ping: '',
        configFileName: 'in_fast.ovpn',
      ),
      LocalVpnServer(
        countryName: 'French',
        countryCode: 'fr',
        ip: '62.171.171.217 ',
        ping: '',
        configFileName: 'eu_fast.ovpn',
      ),
    ];

    // If no VPN is selected, select the first one by default
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty &&
        availableServers.isNotEmpty) {
      setVpnFromLocalServer(availableServers[0]);
    }
  }

  //connect vpn
  void connectToVpn() async {
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);

      final vpnConfig = VpnConfig(
        country: vpn.value.CountryLong,
        username: '',
        password: '',
        config: config,
      );

      _startWaitingTimer();
      await VpnEngine.startVpn(vpnConfig);
    } else {
      _disconnectVpn(showWarning: false);
    }
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
    _remainingSeconds.value = 20;

    _waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds.value > 0) {
        _remainingSeconds.value--;
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
    if (vpnState.value == VpnEngine.vpnConnected) {
      VpnEngine.stopVpn();
    }
    final newVpn = await server.toVpn();
    vpn.value = newVpn;
    Pref.vpn = newVpn;
    _cancelWaitingTimer();

    // Log server selection event
    AnalyticsHelper.logServerSelection(server.countryName, server.countryCode);

    update();
  }

  /// Màu nút kết nối
  Color get getButtonColor {
    return vpnState.value == VpnEngine.vpnConnected
        ? Color(0xFFF15E24)
        : Color(0xFF343A4B);
  }

  /// Nội dung nút kết nối
  Widget get getButtonContent {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Text(
          'TAP TO CONNECT'.tr,
          style: TextStyle(color: Color(0xFF03C343), fontSize: 12.0),
        );
      case VpnEngine.vpnConnected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.privacy_tip, color: Color(0xFF03C343), size: 12),
            SizedBox(width: 5),
            Text(
              'CONNECTED'.tr,
              style: TextStyle(color: Color(0xFF03C343), fontSize: 12.0),
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connecting....'.tr,
              style: TextStyle(color: Color(0xFF03C343), fontSize: 12.0),
            ),
            SizedBox(width: 5),
            Obx(() => CountdownCircle(
                  remainingSeconds: _remainingSeconds.value,
                  totalSeconds: 20,
                  size: 30,
                  progressColor: Color(0xFF03C343),
                  backgroundColor: Color(0xFF767C8A),
                )),
          ],
        );
    }
  }
}
