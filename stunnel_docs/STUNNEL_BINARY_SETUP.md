# 🔐 Stunnel Binary Setup Guide

## ⚠️ Vấn đề hiện tại
Dự án đã được tích hợp Stunnel nhưng cần **Stunnel binary thực** để hoạt động. Hiện tại chỉ có placeholder files.

## 🚀 Giải pháp

### Phương pháp 1: Tải Pre-built Binary (Khuyến nghị)

#### Bước 1: Tải Stunnel Binary
```bash
# Chạy script tải tự động
chmod +x download_stunnel.sh
./download_stunnel.sh
```

#### Bước 2: Tải thủ công từ các nguồn
1. **Guardian Project**: https://github.com/guardianproject/stunnel-android/releases
2. **Official Stunnel**: https://www.stunnel.org/downloads.html
3. **Alternative**: https://github.com/mtrojnar/stunnel/releases

#### Bước 3: Copy vào dự án
```bash
# Giải nén và copy
unzip stunnel-arm64-v8a.zip
cp stunnel android/app/src/main/jniLibs/arm64-v8a/libstunnel.so

unzip stunnel-armeabi-v7a.zip  
cp stunnel android/app/src/main/jniLibs/armeabi-v7a/libstunnel.so

unzip stunnel-x86.zip
cp stunnel android/app/src/main/jniLibs/x86/libstunnel.so

unzip stunnel-x86_64.zip
cp stunnel android/app/src/main/jniLibs/x86_64/libstunnel.so
```

### Phương pháp 2: Build từ Source (Advanced)

#### Yêu cầu:
- Android NDK
- OpenSSL development libraries
- Cross-compilation tools

#### Bước 1: Setup Android NDK
```bash
# Tải Android NDK
wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
unzip android-ndk-r25c-linux.zip

# Set environment
export ANDROID_NDK_HOME=/path/to/android-ndk-r25c
export PATH=$PATH:$ANDROID_NDK_HOME
```

#### Bước 2: Build Stunnel
```bash
# Clone Stunnel source
git clone https://github.com/mtrojnar/stunnel.git
cd stunnel

# Configure cho ARM64
./configure \
    --host=aarch64-linux-android \
    --prefix=/usr/local \
    --with-ssl=/usr/local \
    --disable-shared \
    --enable-static

# Build
make -j$(nproc)

# Copy binary
cp src/stunnel ../android/app/src/main/jniLibs/arm64-v8a/libstunnel.so
```

### Phương pháp 3: Sử dụng Mock Implementation (Testing)

Hiện tại dự án đã có mock implementation để test:

```java
// Từ StunnelEngine.java
if (stunnelFile.exists() && stunnelFile.length() > 1000) {
    // Sử dụng binary thực
} else {
    // Sử dụng mock implementation
    stunnelProcess = createMockStunnelProcess();
}
```

## 🧪 Test Stunnel

### Bước 1: Chạy test
```dart
import 'test_stunnel.dart';

// Test Stunnel
await StunnelTest.testStunnel();
```

### Bước 2: Kiểm tra logs
```bash
# Xem logs
adb logcat | grep StunnelEngine

# Kiểm tra process
adb shell ps aux | grep stunnel
```

### Bước 3: Kiểm tra binary
```bash
# Kiểm tra file size
ls -la android/app/src/main/jniLibs/*/libstunnel.so

# Kiểm tra file type
file android/app/src/main/jniLibs/arm64-v8a/libstunnel.so
```

## 📊 Trạng thái Binary

### ✅ Đã có:
- Placeholder files cho tất cả architectures
- Mock implementation cho testing
- Code đã sẵn sàng

### ❌ Cần thêm:
- Stunnel binary thực cho ARM64
- Stunnel binary thực cho ARMv7
- Stunnel binary thực cho x86
- Stunnel binary thực cho x86_64

## 🔍 Troubleshooting

### 1. Binary không tải được
```bash
# Thử nguồn khác
curl -L -o stunnel.zip "https://github.com/guardianproject/stunnel-android/releases/latest/download/stunnel-android-arm64-v8a.zip"
```

### 2. Binary không chạy
```bash
# Kiểm tra permissions
chmod +x android/app/src/main/jniLibs/*/libstunnel.so

# Kiểm tra architecture
file android/app/src/main/jniLibs/arm64-v8a/libstunnel.so
```

### 3. Mock implementation không hoạt động
- Kiểm tra logs: `adb logcat | grep StunnelEngine`
- Đảm bảo file placeholder có kích thước < 1000 bytes

## 📝 Lưu ý quan trọng

1. **File size check**: Code kiểm tra `stunnelFile.length() > 1000` để phân biệt binary thực và placeholder
2. **Mock fallback**: Nếu không có binary thực, sẽ sử dụng mock implementation
3. **Testing**: Có thể test với mock implementation trước khi có binary thực
4. **Performance**: Mock implementation chỉ dùng cho testing, không phải production

## 🎯 Kết luận

**Để Stunnel hoạt động thực tế trong APK, bạn cần:**
1. Tải Stunnel binary thực từ các nguồn trên
2. Copy vào thư mục `jniLibs` tương ứng
3. Build lại APK
4. Test trên thiết bị thực

**Hiện tại có thể test với mock implementation để kiểm tra code logic!** 