# 🧪 Test Stunnel trên Máy ảo Android

## 📱 Setup Máy ảo Android

### Bước 1: Tạo máy ảo Android
```bash
# Mở Android Studio
# Tools -> AVD Manager -> Create Virtual Device

# Chọn thiết bị (khuyến nghị):
# - Pixel 7 (API 34)
# - Pixel 6 (API 33)
# - Pixel 5 (API 32)

# Chọn System Image:
# - API Level 34 (Android 14)
# - API Level 33 (Android 13)
# - API Level 32 (Android 12)

# Tên máy ảo: stunnel_test_emulator
```

### Bước 2: Khởi động máy ảo
```bash
# Khởi động máy ảo
flutter emulators --launch stunnel_test_emulator

# Hoặc từ Android Studio:
# Tools -> AVD Manager -> Play button
```

### Bước 3: Kiểm tra kết nối
```bash
# Kiểm tra máy ảo đã kết nối
flutter devices

# Kết quả mong đợi:
# Android SDK built for x86_64 (mobile) • emulator-5554 • android-x64 • Android 14 (API 34)
```

## 🚀 Build và Test APK

### Bước 1: Build APK cho máy ảo
```bash
# Build debug APK (nhanh hơn)
flutter build apk --debug

# Build release APK (tối ưu hơn)
flutter build apk --release
```

### Bước 2: Install APK lên máy ảo
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Hoặc install release APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Bước 3: Chạy app
```bash
# Chạy app
adb shell am start -n com.Lutasubin.freeVpn/.MainActivity

# Hoặc từ Flutter
flutter run
```

## 🧪 Test Stunnel trên Máy ảo

### Bước 1: Test Stunnel Binary
```dart
// Trong app, chạy test
import 'test_stunnel_binary.dart';

// Test Stunnel binary thực
await StunnelBinaryTest.testStunnelBinary();

// Test binary detection
await StunnelBinaryTest.testBinaryDetection();
```

### Bước 2: Monitor Logs
```bash
# Xem Stunnel logs
adb logcat | grep StunnelEngine

# Xem tất cả logs
adb logcat

# Clear logs trước khi test
adb logcat -c
```

### Bước 3: Test VPN Connection
```dart
// Test VPN qua Stunnel
import 'package:your_app/services/stunnel_engine.dart';
import 'package:your_app/services/vpn_engine.dart';

// 1. Khởi động Stunnel
final stunnelSuccess = await StunnelEngine.startStunnel(stunnelConfig);
if (!stunnelSuccess) {
  print('❌ Stunnel failed to start');
  return;
}

// 2. Đợi Stunnel kết nối
await Future.delayed(Duration(seconds: 2));

// 3. Khởi động WireGuard qua Stunnel
final wireguardSuccess = await VpnEngine.startWireGuard('wg-stunnel-tunnel', wireguardConfig);
if (!wireguardSuccess) {
  print('❌ WireGuard failed to start');
  return;
}

print('✅ VPN connected via Stunnel!');
```

## 📊 Expected Results trên Máy ảo

### 1. Binary Detection:
```
I/StunnelEngine: Using local Stunnel binary: /data/app/.../lib/x86_64/libstunnel.so
I/StunnelEngine: Binary size: 102400 bytes
```

### 2. Stunnel Connection:
```
I/StunnelEngine: Stunnel output: stunnel started
I/StunnelEngine: Status: connected
```

### 3. Mock Fallback (nếu binary không chạy):
```
W/StunnelEngine: Failed to execute Stunnel binary, using mock implementation
I/StunnelEngine: Status: connected (mock)
```

## 🔍 Troubleshooting trên Máy ảo

### 1. Máy ảo không khởi động
```bash
# Kiểm tra AVD
flutter emulators

# Khởi động lại
flutter emulators --launch stunnel_test_emulator
```

### 2. APK không install được
```bash
# Uninstall app cũ
adb uninstall com.Lutasubin.freeVpn

# Install lại
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 3. Stunnel không chạy
```bash
# Kiểm tra binary
adb shell ls -la /data/app/*/lib/*/libstunnel.so

# Kiểm tra permissions
adb shell chmod +x /data/app/*/lib/*/libstunnel.so

# Xem logs chi tiết
adb logcat | grep -E "(StunnelEngine|stunnel)"
```

### 4. VPN không kết nối
```bash
# Kiểm tra network
adb shell ping 8.8.8.8

# Kiểm tra VPN service
adb shell dumpsys connectivity
```

## 📈 Performance Testing trên Máy ảo

### 1. Memory Usage:
```bash
# Monitor memory
adb shell dumpsys meminfo com.Lutasubin.freeVpn
```

### 2. CPU Usage:
```bash
# Monitor CPU
adb shell top -p $(adb shell pidof com.Lutasubin.freeVpn)
```

### 3. Network Traffic:
```bash
# Monitor network
adb shell dumpsys netstats
```

## 🎯 Test Cases

### Test Case 1: Binary Detection
- [ ] Binary file tồn tại
- [ ] File size > 1000 bytes
- [ ] Binary có thể execute
- [ ] Fallback về mock nếu fail

### Test Case 2: Stunnel Connection
- [ ] Stunnel khởi động thành công
- [ ] Config file được tạo đúng
- [ ] Process chạy ổn định
- [ ] Status update đúng

### Test Case 3: VPN Integration
- [ ] WireGuard kết nối qua Stunnel
- [ ] Traffic được tunnel đúng
- [ ] Connection stable
- [ ] Disconnect clean

### Test Case 4: Error Handling
- [ ] Binary không tồn tại → Mock
- [ ] Binary fail → Mock
- [ ] Network error → Retry
- [ ] Timeout → Error message

## 📝 Lưu ý quan trọng

1. **Máy ảo x86_64**: Stunnel binary sẽ chạy trên x86_64 architecture
2. **Performance**: Máy ảo chậm hơn thiết bị thực
3. **Network**: Máy ảo có thể có network issues
4. **Root access**: Máy ảo thường không có root
5. **VPN permissions**: Cần grant VPN permissions trên máy ảo

## 🚀 Kết luận

**Máy ảo Android là môi trường test tốt cho Stunnel vì:**
- ✅ Dễ setup và reset
- ✅ Có thể test nhiều Android versions
- ✅ Debug logs dễ dàng
- ✅ Không ảnh hưởng thiết bị thực

**Bước tiếp theo:**
1. Setup máy ảo Android
2. Build và install APK
3. Test Stunnel functionality
4. Monitor logs và performance
5. Test trên thiết bị thực nếu cần 