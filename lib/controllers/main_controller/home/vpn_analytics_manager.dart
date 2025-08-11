import 'package:flutter/material.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/view/screens/menu/rate/rate_screen.dart';

/// Quản lý analytics và rating của VPN
class VpnAnalyticsManager {
  
  /// Log VPN connection event
  static void logVpnConnect(String country, String countryCode) {
    AnalyticsHelper.logVpnConnect(country, countryCode);
  }
  
  /// Log VPN disconnection event with duration
  static void logVpnDisconnect(String country, int durationInSeconds) {
    AnalyticsHelper.logVpnDisconnect(country, durationInSeconds);
  }
  
  /// Log server selection event
  static void logServerSelection(String country, String countryCode) {
    AnalyticsHelper.logServerSelection(country, countryCode);
  }
  
  /// Increment connection attempts and check for rating display
  static void incrementConnectionAttempts(BuildContext context) {
    if (!Pref.hasShownRating) {
      int attempts = Pref.connectionAttempts + 1;
      Pref.connectionAttempts = attempts;
      
      if (attempts >= 2) {
        Future.delayed(const Duration(seconds: 1), () {
          showRatingScreen(context);
        });
      }
    }
  }
  
  /// Show rating screen
  static void showRatingScreen(BuildContext context) {
    Pref.hasShownRating = true;
    Pref.resetConnectionAttempts();
    showRatingBottomSheet2(context);
  }
  
  /// Show rating bottom sheet
  static void showRatingBottomSheet2(BuildContext context) {
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
  
  /// Log connection error event
  static void logConnectionError(String error, String serverType) {
    // Add your analytics logging for errors here
    print('Analytics: Connection error - $error on $serverType');
  }
  
  /// Log connection retry event
  static void logConnectionRetry(int attemptNumber, String serverType) {
    // Add your analytics logging for retry attempts here
    print('Analytics: Connection retry attempt $attemptNumber for $serverType');
  }
  
  /// Log connection timeout event
  static void logConnectionTimeout(String serverType) {
    // Add your analytics logging for timeout here
    print('Analytics: Connection timeout for $serverType');
  }
}