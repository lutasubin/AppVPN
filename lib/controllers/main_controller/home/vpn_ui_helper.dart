import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';

/// Helper class để xử lý UI của VPN
class VpnUIHelper {
  
  /// Get button content based on VPN state
  static Widget getButtonContent(String vpnState, int countdownSeconds) {
    switch (vpnState) {
      case VpnEngine.vpnDisconnected:
      case VpnEngine.vpnPrepare:
        return _buildButtonText('Connect'.tr, 20);
      
      case VpnEngine.vpnConnected:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildButtonText('Connected'.tr, 18),
          ],
        );
      
      case VpnEngine.vpnConnecting:
      case VpnEngine.vpnWaitConnection:
      case VpnEngine.vpnAuthenticating:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildButtonText('Connecting....'.tr, 18),
            const SizedBox(height: 4),
            _buildButtonText('${countdownSeconds}s', 14),
          ],
        );
      
      default:
        return _buildButtonText('Waiting....'.tr, 18);
    }
  }
  
  /// Build button text widget
  static Widget _buildButtonText(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  /// Get button gradient based on VPN state
  static LinearGradient getButtonGradient() {
    const connectedColors = [Color(0xFF15EDB3), Color(0xFF2484F1)];
    
    return LinearGradient(
      colors: connectedColors,
      stops: List.generate(
          connectedColors.length, (i) => i / (connectedColors.length - 1)),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}