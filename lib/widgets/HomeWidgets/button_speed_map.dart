import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconTextButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback onTap;

  const IconTextButton({
    Key? key,
    required this.svgAsset,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF172032), // màu nền gần giống hình (xám đậm)
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withOpacity(0.05), // viền nhẹ
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
