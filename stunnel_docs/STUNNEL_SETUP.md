# 🔐 Stunnel Setup Guide

## 📋 Tổng quan
Dự án đã được tích hợp Stunnel để tăng cường bảo mật cho kết nối VPN. Stunnel hoạt động như một tunnel SSL/TLS, giúp ẩn traffic VPN trong traffic HTTPS thông thường.

## 🚀 Cài đặt Stunnel Binary

### Phương pháp 1: Build từ source (Khuyến nghị)
```bash
# Chạy script build
chmod +x build_stunnel.sh
./build_stunnel.sh
```

### Phương pháp 2: Tải pre-built binary
1. Tải Stunnel binary cho Android từ: https://github.com/guardianproject/stunnel-android/releases
2. Copy vào thư mục `android/app/src/main/jniLibs/` cho từng architecture:
   - `arm64-v8a/libstunnel.so`
   - `armeabi-v7a/libstunnel.so`
   - `x86/libstunnel.so`
   - `x86_64/libstunnel.so`

## 🔧 Cấu hình

### 1. Stunnel Config (`assets/stunnel/stunnelclient.conf`)
```ini
[wireguard]
verify = 0
client = yes
accept = 127.0.0.1:51820
connect = 144.126.138.95:443
```

### 2. WireGuard Config (qua Stunnel)
```ini
[Interface]
PrivateKey = your_private_key
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = server_public_key
Endpoint = 127.0.0.1:51820  # Kết nối qua Stunnel local
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## 🧪 Test Stunnel

### 1. Chạy test script
```dart
// Import và sử dụng
import 'test_stunnel.dart';

// Test Stunnel
await StunnelTest.testStunnel();
```

### 2. Kiểm tra logs
```bash
# Xem logs Stunnel
adb logcat | grep StunnelEngine

# Kiểm tra process
adb shell ps aux | grep stunnel
```

## 📱 Sử dụng trong App

### 1. Khởi động Stunnel
```dart
import 'package:your_app/services/stunnel_engine.dart';

// Khởi động Stunnel
final stunnelSuccess = await StunnelEngine.startStunnel(stunnelConfig);
if (!stunnelSuccess) {
  throw Exception('Failed to start Stunnel tunnel');
}
```

### 2. Khởi động WireGuard qua Stunnel
```dart
// Đợi Stunnel kết nối
await Future.delayed(Duration(seconds: 2));

// Khởi động WireGuard qua Stunnel
final wireguardSuccess = await VpnEngine.startWireGuard('wg-stunnel-tunnel', wireguardConfig);
```

### 3. Ngắt kết nối
```dart
// Dừng WireGuard trước
await VpnEngine.stopWireGuard();

// Sau đó dừng Stunnel
await StunnelEngine.stopStunnel();
```

## 🔍 Troubleshooting

### 1. Stunnel không khởi động
- Kiểm tra binary có tồn tại không
- Kiểm tra permissions
- Xem logs: `adb logcat | grep StunnelEngine`

### 2. WireGuard không kết nối qua Stunnel
- Đợi Stunnel kết nối hoàn toàn
- Kiểm tra config WireGuard có đúng endpoint không
- Tăng timeout cho Stunnel

### 3. Performance issues
- Tăng timeout cho Stunnel
- Kiểm tra server Stunnel có ổn định không

## 📊 Performance Metrics
- **Connection time**: ~3-5 giây (bao gồm Stunnel + WireGuard)
- **Latency overhead**: ~10-20ms (do Stunnel tunnel)
- **Memory usage**: ~5-10MB cho Stunnel process

## 🔒 Security Benefits
1. **Traffic obfuscation**: Ẩn traffic VPN trong HTTPS
2. **Firewall bypass**: Vượt qua firewall dễ dàng hơn
3. **Deep packet inspection**: Khó bị phát hiện hơn
4. **Port 443**: Sử dụng port HTTPS chuẩn

## 📝 Lưu ý
- Đảm bảo server Stunnel đã được cấu hình đúng
- Test trên nhiều thiết bị khác nhau
- Monitor performance và stability
- Backup config files trước khi deploy 