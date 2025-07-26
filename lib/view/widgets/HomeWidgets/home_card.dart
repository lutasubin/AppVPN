import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget icon;

  const HomeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * 0.65, // Giới hạn chiều rộng
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Giữ layout nhỏ gọn
            children: [
              icon,
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1, // Ép buộc hiển thị trên 1 dòng
                overflow: TextOverflow
                    .ellipsis, // Cắt ngắn nếu quá dài// Căn giữa tiêu đề
                style: const TextStyle(
                  color: Color(0xFF03C343),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center, // Căn giữa nội dung phụ
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF03C343),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
