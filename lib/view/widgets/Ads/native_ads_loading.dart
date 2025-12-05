import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NativeAdShimmerPremiumDark extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final double? height;
  
  const NativeAdShimmerPremiumDark({
    super.key,
    this.margin,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu height nhỏ (120 hoặc tương tự) để dùng layout compact
    final bool isCompact = height != null && height! <= 150;
    
    return Container(
      margin: margin ?? const EdgeInsets.all(12),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        decoration: BoxDecoration(
          color: const Color(0xFF172032),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2C),
          highlightColor: const Color(0xFF3A3A3C),
          child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
        ),
      ),
    );
  }

  // Layout cho height nhỏ (120px)
  Widget _buildCompactLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        // Content
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10, width: 120, color: Colors.black),
              const SizedBox(height: 6),
              Container(height: 8, width: 80, color: Colors.black),
              const SizedBox(height: 8),
              Container(height: 8, width: double.infinity, color: Colors.black),
              const SizedBox(height: 4),
              Container(height: 8, width: 180, color: Colors.black),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Button
        Container(
          width: 70,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  // Layout cho height lớn (350px)
  Widget _buildFullLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + lines
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 140, color: Colors.black),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 100, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 10,
          width: double.infinity,
          color: Colors.black,
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          width: double.infinity,
          color: Colors.black,
        ),
        const SizedBox(height: 6),
        Container(height: 10, width: 220, color: Colors.black),
        const SizedBox(height: 14),
        Container(
          height: 38,
          width: double.infinity,
          color: Colors.black,
        ),
      ],
    );
  }
}