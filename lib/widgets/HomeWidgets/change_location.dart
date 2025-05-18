// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ChangeLocation extends StatelessWidget {
  final String title, ip;
  final Widget icon;

  ChangeLocation({
    Key? key,
    required this.ip,
    required this.icon,
      required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Row(
      children: [
        icon,
        SizedBox(
          width: 30,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                 color: Color(0xFFFFFFFF), ),
            ),
            Text(
              ip,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF767C8A), ),
            )
          ],
        )
      ],
    ));
  }
}
