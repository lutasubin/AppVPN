<div align="center">
  <h1>AI VPN Fast Safe</h1>
  <p>Ứng dụng VPN Flutter hỗ trợ OpenVPN · WireGuard · Stunnel · Firebase · Ads</p>
  <p>
    <img src="screenshot/image.png" width="220" />
    <img src="screenshot/image1.png" width="220" />
    <img src="screenshot/image2.png" width="220" />
  </p>
</div>

---

## Giới thiệu nhanh
- Flutter app đa nền tảng tập trung Android, version `2.1.0+30`, yêu cầu Flutter/Dart `>=3.6`.
- Quản lý trạng thái và điều hướng bằng GetX, chia theo từng controller (home, location, speed test, purchase…).
- Hỗ trợ ba nguồn VPN: tệp `.ovpn` nội bộ, API [VPNGate](https://www.vpngate.net), WireGuard/Stunnel thông qua native bridge.
- Tích hợp Firebase (Core, Analytics, Remote Config, Crashlytics), Google Mobile Ads, In-App Purchase, Hive, SharedPreferences.
- Thiết kế UI hiện đại, đa ngôn ngữ (16+), có speed-test giả lập, quản lý quảng cáo động, purchase unlock máy chủ pro.

---

## Tính năng nổi bật
- **Kết nối VPN 1 chạm**: trạng thái thời gian thực, đếm thời lượng, thống kê upload/download.
- **Đa giao thức**: OpenVPN (assets + VPNGate), WireGuard API, WireGuard qua Stunnel với cleanup client chủ động.
- **Quản lý server thông minh**: tách rõ server free/pro, gợi ý quốc kỳ, analytics log khi chọn/kết nối.
- **Kiểm tra mạng & IP**: speed-test mượt (fake data để demo), tra IP bằng `ip-api.com`.
- **Đa ngôn ngữ & theme**: lưu vào Hive, tự nhận ngôn ngữ thiết bị.
- **Monetization**: Remote Config điều khiển banner/native/interstitial/rewarded/app-open ads, toggle ẩn quảng cáo, purchase nâng cấp.
- **Quan sát số liệu**: Firebase Analytics log app-open, hành vi connect/disconnect, Crashlytics xử lý lỗi nền.

---

## Kiến trúc & Thư mục chính
- **`lib/main.dart`**: khởi tạo splash, Firebase, Analytics, Remote Config, hạn chế block UI bằng `unawaited`.
- **`lib/appVpn.dart`**: `GetMaterialApp`, binding `AppBinding`, lifecycle handler, init quảng cáo khi tree sẵn sàng.
- **Controllers** tách module:
  - `controllers/main_controller/home/*`: state manager, server manager, connection service, analytics, cleanup client.
  - `controllers/main_controller/location`, `network`, `speed`, `purchase`, `splash`.
  - `controllers/ads_controller/*`: wrap Google Mobile Ads.
- **Services**:
  - `services/vpn_engine.dart`: MethodChannel bridge tới native (OpenVPN/WireGuard, kill switch, stage stream).
  - `apis/vpn_gate.dart`: fetch CSV VPNGate, cache vào Hive Pref.
  - `apis/local_vpn.dart`: danh sách server assets (free/pro/stunnel/wireguard-api).
  - `helpers/remote_config/config_firebase.dart`: cache/tự refresh Remote Config + ad id + API token.
- **Android native**:
  - `android/app`: app chính.
  - `android/vpnLib`: thư viện native (C/C++/OpenVPN bridge) hỗ trợ build với trang 16KB (Android 15+).
  - `android/vpnLib/tunnel`: nguồn OpenVPN/WireGuard, script build.

```
lib/
├─ apis/                # VPNGate + WireGuard service client
├─ controllers/
│  ├─ ads_controller/   # Native/Banner controller
│  └─ main_controller/
│      ├─ home/         # State/server/connection managers
│      ├─ location/     # Country picker
│      ├─ network/      # Connectivity status
│      └─ speed/        # Speed test simulator
├─ helpers/
│  ├─ Hive/pref.dart    # Local storage (language, selection…)
│  ├─ ads/ad_helper.dart
│  ├─ Firebase_Analytics/
│  ├─ lang/             # Translations
│  └─ remote_config/
├─ models/              # LocalVpnServer, Vpn, VpnStatus…
├─ services/            # VpnEngine method channel
└─ view/                # UI screens/components
assets/
├─ vpn/*.ovpn           # OpenVPN profiles (ignored nếu chứa bí mật)
├─ stunnel/*.conf       # WireGuard-over-Stunnel config
├─ flags/, svg/, images/, lottie/
```

---

## Luồng kết nối VPN
1. **Chọn server** (free/pro/stunnel/wireguard-api hoặc VPNGate API) → `LocalController` cập nhật `VpnServerManager`.
2. **Connect** → `VpnConnectionService` xác định giao thức:
   - `OpenVPN` nội bộ: đọc `.ovpn` từ `assets/vpn`.
   - `VPNGate API`: decode config base64 từ API CSV.
   - `WireGuard API`: lấy token từ Remote Config (`api_token`), nhận config runtime.
   - `Stunnel + WireGuard`: copy `.conf` từ `assets/stunnel`, build client, cleanup tự động.
3. `VpnEngine` gọi native qua MethodChannel (`start`, `stop`, `startWireGuard`, `stopWireGuard`).
4. `VpnStateManager` lắng nghe event channel `vpnStage`/`vpnStatus`, cập nhật UI + countdown.
5. Khi disconnect, `VpnAnalyticsManager` log duration, `VpnClientCleanupManager` xóa interface còn tồn tại.

---

## Phụ thuộc chính
- UI & state: `flutter`, `get`, `lottie`, `flutter_svg`, `percent_indicator`, `syncfusion_flutter_gauges`.
- Lưu trữ/cấu hình: `hive`, `hive_flutter`, `shared_preferences`, `flutter_dotenv` (chuẩn bị sẵn nếu cần).
- Mạng: `http`, `dio`, `connectivity_plus`, `csv`, `url_launcher`.
- Monetization & services: `google_mobile_ads`, `firebase_core`, `firebase_remote_config`, `firebase_analytics`, `firebase_crashlytics`, `in_app_purchase`, `store_redirect`, `share_plus`.
- Tiện ích khác: `intl`, `installed_apps`, `flutter_native_splash`.

---

## Chuẩn bị môi trường
1. **Công cụ**: Flutter SDK ≥3.6, Android Studio (SDK 34+), NDK 28 (nếu build `vpnLib`), Java 17.
2. **Firebase**:
   - Tạo project, kích hoạt Analytics, Remote Config, Crashlytics.
   - Tải `google-services.json` → đặt vào `android/app/`.
   - Cập nhật `lib/firebase_options.dart` bằng `flutterfire configure`.
3. **AdMob / Remote Config**:
   - Tạo Ad Unit IDs (App Open, Banner, Native, Rewarded, Interstitial).
   - Tạo keys trong Remote Config: `show_ads`, `banner_ad`, `native_ad`, `native1_ad`, `native2_ad`, `interstitial_ad`, `rewarded_ad`, `open_ad`, `ad_request_timeout`, `retry_delay`, `max_retries`, `api_token`, `nuoc_anh`, `nuoc_my`, `nuoc_phap`, `nuoc_sin`.
4. **Các file cấu hình VPN**:
   - `assets/vpn/*.ovpn` cho server nội bộ (free/pro).
   - `assets/stunnel/*.conf`, `stunnel_binary` nếu dùng WireGuard-over-Stunnel.
   - Không commit các file chứa thông tin nhạy cảm.

---

## Thiết lập & chạy ứng dụng
```bash
git clone <repo>
cd AppVPN-VpnAppUpdate
flutter pub get
# (tuỳ chọn) tạo build runner nếu cần
flutter run --flavor development -d <device_id>
```

- **Splash/Icon**: cấu hình trong `pubspec.yaml` (`flutter_native_splash`, `flutter_launcher_icons`).
- **Hive box**: được mở tự động qua `Pref.initializeHive()` trước khi render UI.
- **Debug ads**: bật `Config.showAds = false` qua Remote Config để tránh hiển thị.

---

## Cấu hình VPN chi tiết
### OpenVPN (assets)
1. Đặt `.ovpn` trong `assets/vpn/` với naming trùng `configFileName` ở `lib/apis/local_vpn.dart`.
2. Nếu cần credential, embed trực tiếp trong file `.ovpn` hoặc truyền qua `VpnConfig.username/password`.
3. Cập nhật `pubspec.yaml` để include đường dẫn này (đã sẵn).

### WireGuard API
1. Sử dụng API riêng trả về config string (định dạng `.conf`).
2. Token gọi API đọc từ Remote Config `api_token`.
3. Server list khởi tạo trong `wireguardApiVpn`, có thể mở rộng.

### Stunnel + WireGuard
1. `assets/stunnel/*.conf` + `stunnel_binary`.
2. Script `assets/stunnel/generate_certs.sh` giúp tạo chứng chỉ dev.
3. Khi connect, app copy file tạm, khởi chạy client, cleanup trong `VpnClientCleanupManager`.

---

## Màn hình chính
1. **Splash**: native splash + Flutter splash (animation + ads precache).
2. **Home**: nút connect, hiển thị tốc độ, countdown, status chip, show ads theo Remote Config.
3. **Location**: chọn server, xem ping/IP/flag, filter free/pro/API.
4. **Connected / Disconnected**: UI riêng cho trạng thái; disconnect có rewarded ad tuỳ chọn.
5. **Network Test**: gauge mô phỏng download/upload, hiển thị Mb/s.
6. **Settings**: chọn ngôn ngữ, chia sẻ app, đánh giá, chính sách bảo mật, kill switch (open native settings), show installed VPN apps.
7. **Language**: GetX translations (16+).
8. **Rating / Feedback / Privacy**: modal + external links.

---

## Phát hành & build native
### Flutter build
```bash
flutter build apk --split-per-abi
flutter build appbundle
```
- Kiểm tra `android/app/build.gradle` đã cấu hình `applicationId`, versionCode/versionName khớp pubspec.
- Sử dụng keystore riêng, cập nhật `key.properties`.

### Build `vpnLib` với page size 16KB (Android 15)
```powershell
cd android
.\gradlew :vpnLib:assembleRelease -PbuildNativeFromSource=true
```
- Copy `.so` tạo ra sang `android/vpnLib/src/main/jniLibs/<abi>/`.
- Xác thực bằng `llvm-readelf -W -l ... | Select-String "MaxPageSize"`.

---

## Kiểm thử & chất lượng
- Chạy `flutter test` (hiện chưa có nhiều test → nên bổ sung widget/unit test cho controller quan trọng).
- Sử dụng `flutter analyze` để đảm bảo tuân thủ `flutter_lints`.
- Manual test checklist:
  - Kết nối/Ngắt cả OpenVPN/WireGuard.
  - Thay đổi server khi đang connect (được block đúng).
  - Remote Config offline fallback (cache).
  - Ads enable/disable qua Remote Config.
  - Purchase unlock server pro.

---

## Bảo mật & Quyền riêng tư
- Không commit file cấu hình thực (`assets/vpn`, `assets/stunnel`) lên repo công khai.
- Ẩn API token bằng Remote Config, không hardcode trong client.
- Crashlytics bật thu thập dữ liệu → cập nhật chính sách bảo mật tương ứng.
- Cân nhắc thêm certificate pinning hoặc HTTPS bắt buộc khi gọi API WireGuard riêng.

---

## Troubleshooting
- **Không kết nối được VPN**: kiểm tra `VpnEngine.start` log qua `adb logcat`, đảm bảo file `.ovpn` hợp lệ.
- **Remote Config timeout**: app có cache 2h trong SharedPreferences, dùng `Config.forceRefresh()` để thử lại.
- **Ads không hiện**: xác nhận `Config.showAds == true` và ad unit hợp lệ; dùng test ID khi debug.
- **WireGuard cleanup lỗi**: gọi `LocalController.forceCleanupAllClients()` từ debug menu hoặc xoá app data.
- **Android 15 crash**: chắc chắn native `.so` build với `-Wl,-z,max-page-size=16384`.

---

## Paper trail
- Tác giả ban đầu: **DucThanhNguyen**. Vui lòng giữ credit khi fork/phát hành.

---

## Đóng góp
1. Fork & tạo branch.
2. Giữ code style chuẩn `flutter format` và `flutter_lints`.
3. Tạo PR kèm mô tả, screenshot (nếu ảnh hưởng UI) và bước test.

Chúc bạn triển khai VPN app an toàn và tối ưu! 🚀