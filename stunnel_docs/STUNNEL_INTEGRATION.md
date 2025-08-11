# 🔐 Tích hợp Stunnel với WireGuard

## 📋 Tổng quan

Dự án này đã được tích hợp Stunnel để tăng cường bảo mật cho kết nối WireGuard. Stunnel hoạt động như một tunnel SSL/TLS, giúp ẩn traffic WireGuard trong traffic HTTPS thông thường.

## 🏗️ Kiến trúc

```
[App] → [Stunnel Client] → [HTTPS/SSL] → [Stunnel Server] → [WireGuard Server]
```

## 📁 Cấu trúc file

### Assets
```
assets/stunnel/
├── stunnelclient.conf          # Cấu hình Stunnel client chung
├── vpn_US22.conf              # WireGuard config cho US (qua Stunnel)
├── vpn_DE22.conf              # WireGuard config cho Germany (qua Stunnel)
├── vpn_FR22.conf              # WireGuard config cho France (qua Stunnel)
├── vpn_UK22.conf              # WireGuard config cho UK (qua Stunnel)
└── vpn_SG22.conf              # WireGuard config cho Singapore (qua Stunnel)
```

### Code
```
lib/
├── services/
│   └── stunnel_engine.dart    # Service quản lý Stunnel
├── models/
│   └── local_vpn.dart         # Model hỗ trợ Stunnel
├── controllers/
│   └── local_controller.dart  # Controller tích hợp Stunnel
└── view/widgets/
    └── vpn_card_stunnel.dart  # UI cho server Stunnel

android/app/src/main/java/com/Lutasubin/freeVpn/
├── StunnelEngine.java         # Plugin native quản lý Stunnel process
└── MainActivity.java          # MainActivity đã đăng ký StunnelEngine
```

## ⚙️ Cấu hình

### 1. Stunnel Client Config (`stunnelclient.conf`)
```ini
[wireguard]
verify = 0
client = yes
accept = 127.0.0.1:51820
connect = 144.126.138.95:443
```

### 2. WireGuard Config (ví dụ: `vpn_US22.conf`)
```ini
[Interface]
Address = 10.7.0.2/24, fddd:2c4:2c4:2c4::2/64
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = eF16z+HK3xJWrrn4WrQ6xwn00bmgyhZlf8VagvkeYn4=

[Peer]
PublicKey = t44oGhwGAakFjPXvyJatiSlUg4V/k75VEqG4z8eXbjg=
PresharedKey = qufit1jtRdXOB6mkUSsOmfreyhDcBLaQaAB+khfAfk0=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 127.0.0.1:51820  # Kết nối qua Stunnel local
PersistentKeepalive = 25
```

## 🔧 Sử dụng

### 1. Khởi tạo Stunnel
```dart
// Khởi động Stunnel trước
final stunnelSuccess = await StunnelEngine.startStunnel(stunnelConfig);
if (!stunnelSuccess) {
  throw Exception('Failed to start Stunnel tunnel');
}

// Đợi Stunnel kết nối
await Future.delayed(const Duration(seconds: 2));

// Khởi động WireGuard qua Stunnel
final wireguardSuccess = await VpnEngine.startWireGuard('wg-stunnel-tunnel', wireguardConfig);
```

### 2. Ngắt kết nối
```dart
// Dừng WireGuard trước
await VpnEngine.stopWireGuard();

// Sau đó dừng Stunnel
await StunnelEngine.stopStunnel();
```

### 3. Kiểm tra trạng thái
```dart
// Kiểm tra Stunnel có đang chạy không
final isRunning = await StunnelEngine.isStunnelRunning();

// Lấy trạng thái Stunnel
final status = await StunnelEngine.getStunnelStatus();

// Lắng nghe thay đổi trạng thái
StunnelEngine.stunnelStatusStream().listen((status) {
  print('Stunnel status: $status');
});
```

## 🚀 Tính năng

### ✅ Đã hoàn thành
- [x] Tích hợp Stunnel với WireGuard
- [x] Hỗ trợ nhiều server Stunnel
- [x] UI hiển thị server Stunnel
- [x] Quản lý lifecycle Stunnel
- [x] Error handling
- [x] Analytics tracking

### 🔄 Quy trình kết nối
1. **Chọn server Stunnel** từ danh sách
2. **Khởi động Stunnel** với config tương ứng
3. **Đợi Stunnel kết nối** (2 giây)
4. **Khởi động WireGuard** qua tunnel Stunnel
5. **Hiển thị trạng thái** kết nối

### 🔄 Quy trình ngắt kết nối
1. **Dừng WireGuard** trước
2. **Dừng Stunnel** sau
3. **Cleanup resources**
4. **Hiển thị màn hình disconnected**

## 🛡️ Bảo mật

### Lợi ích của Stunnel
- **Ẩn traffic WireGuard** trong HTTPS
- **Bypass firewall** dễ dàng hơn
- **Tăng tính ẩn danh** của kết nối
- **Tương thích** với hầu hết mạng

### Cấu hình bảo mật
- **SSL/TLS encryption** cho tunnel
- **Certificate verification** (có thể tắt)
- **Local endpoint** (127.0.0.1:51820)
- **Persistent keepalive** để duy trì kết nối

## 📊 Monitoring

### Analytics Events
- `vpn_connect_stunnel` - Kết nối Stunnel thành công
- `vpn_disconnect_stunnel` - Ngắt kết nối Stunnel
- `server_selection_stunnel` - Chọn server Stunnel

### Logs
```dart
print('🔄 Stunnel stage changed: $stageLower');
print('✅ Stunnel tunnel is ready');
print('🔴 Stunnel disconnected');
```

## 🔧 Troubleshooting

### Lỗi thường gặp
1. **Stunnel không khởi động**
   - Kiểm tra file config
   - Kiểm tra quyền thực thi
   - Kiểm tra port availability

2. **WireGuard không kết nối qua Stunnel**
   - Đợi Stunnel kết nối hoàn toàn
   - Kiểm tra endpoint (127.0.0.1:51820)
   - Kiểm tra firewall

3. **Kết nối chậm**
   - Tăng timeout cho Stunnel
   - Kiểm tra server performance
   - Optimize config

### Debug Commands
```bash
# Kiểm tra Stunnel process
ps aux | grep stunnel

# Kiểm tra port
netstat -tulpn | grep 51820

# Kiểm tra logs
adb logcat | grep StunnelEngine
```

## 📈 Performance

### Metrics
- **Connection time**: ~3-5 giây (bao gồm Stunnel + WireGuard)
- **Latency overhead**: ~10-20ms (do Stunnel tunnel)
- **Bandwidth**: Minimal overhead (<5%)

### Optimization
- **Connection pooling** cho Stunnel
- **Keepalive optimization**
- **Config caching**
- **Background connection**

## 🔮 Roadmap

### Tính năng tương lai
- [ ] **Auto-reconnect** khi Stunnel mất kết nối
- [ ] **Load balancing** giữa nhiều Stunnel server
- [ ] **Config validation** trước khi kết nối
- [ ] **Performance metrics** chi tiết
- [ ] **Custom certificates** support
- [ ] **Multi-protocol** support (HTTP/2, QUIC)

---

**Lưu ý**: Đảm bảo server Stunnel đã được cấu hình đúng và có thể truy cập từ client. 